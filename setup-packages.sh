#!/bin/bash

if [[ "$OSTYPE" == "linux-gnu" ]]; then
  if [ -f /etc/debian_version ]; then
    ! COMMENTED_DEB_SRC=$(grep "# deb-src" /etc/apt/sources.list | grep -v partner)
    if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
      echo "There are commented out deb-src directives in /etc/apt/sources.list; you may want to enable them." 1>&2
    fi

    sudo apt-get update -y

    ! XORG_INSTALLED=$(dpkg -l | grep xserver-xorg-core | grep "ii  xserver-xorg-core")
    if [[ ${PIPESTATUS[0]} -eq 0 ]]; then
      sudo apt-get install -y xclip
    fi

    sudo apt-get install -y \
      vim \
      tmux \
      tree \
      sysstat \
      software-properties-common \
      colordiff \
      python-pip \
      postgresql-client-common \
      postgresql-client-10 \
      # End apt-get install.

    # Install general development environment.
    if [[ `apt-cache search linux-tools-generic` == "" ]]; then
      sudo apt-get install -y linux-tools
    else
      sudo apt-get install -y linux-tools-generic
    fi
    sudo apt-get install -y git build-essential gdb patch

    # Postgres dev dependencies.
    # Original commands from: https://blog.2ndquadrant.com/testing-new-postgresql-versions-without-messing-up-your-install/
    sudo apt-get -y install flex zlib1g-dev bison # libreadline-dev
    # To run Postgres `make check world`.
    sudo apt-get -y install xsltproc libxml2-utils
    sudo apt-get -y build-dep postgresql

    ! ANSIBLE_PPA_INSTALLED=$(grep -q "^deb .*ansible/ansible" /etc/apt/sources.list /etc/apt/sources.list.d/*)
    if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
      sudo apt-add-repository --yes --update ppa:ansible/ansible
      sudo apt-get -y install ansible
    fi
    pip install jmespath

    pip install -U platformio

    ARCH=$(arch)
    ONEPASSWORD_ARCH="$ARCH"
    if [[ "$ARCH" -eq "x86_64" ]]; then
      ONEPASSWORD_ARCH="amd64"
    fi
    ONEPASSWORD_URL=$(curl https://app-updates.agilebits.com/product_history/CLI | grep -o -E 'https://cache\.agilebits\.com/dist/1P/op/pkg/v[0-9]+\.[0-9]+\.[0-9]+/op_linux_'"$ONEPASSWORD_ARCH"'_v[0-9]+\.[0-9]+\.[0-9]+\.zip' | head -n 1)
    mkdir /tmp/1password-cli
    pushd /tmp/1password-cli
    curl "$ONEPASSWORD_URL" -o cli.zip
    rm -rf /tmp/1password-cli # Ensure idempotency if earlier failure.
    unzip cli.zip
    ! ONEPASSWORD_GPG_KEY_INSTALLED=$(gpg --list-keys 3FEF9748469ADBE15DA7CA80AC2D62742012EA22)
    if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
      gpg --receive-keys 3FEF9748469ADBE15DA7CA80AC2D62742012EA22
    fi
    gpg --verify op.sig op
    sudo mv op /usr/bin/
    popd
    rm -rf /tmp/1password-cli
    echo "Would you like to configure 1Password CLI?"
    select CONFIGURE_1PASSWORD in "Yes" "No"; do
      case $CONFIGURE_1PASSWORD in
        Yes ) 
          op signin my.1password.com jtc331@gmail.com
          break 
          ;;
        No ) break ;;
      esac
    done

    # OpenVPN is supported automatically by Elementary, so
    # for now I don't need this section.
    # # Install OpenVPN.
    # ! OPENVPN_GPG_KEY_INSTALLED=$(gpg --list-keys E158C569)
    # if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    #   wget -O - https://swupdate.openvpn.net/repos/repo-public.gpg | sudo apt-key add -
    # fi
    # sudo echo "deb http://build.openvpn.net/debian/openvpn/release/2.4 xenial main" > /etc/apt/sources.list.d/openvpn-aptrepo.list
    #
    # sudo apt-get update && sudo apt-get install openvpn

  elif [ -f /etc/redhat-release ]; then
    echo "This is a RedHat based distro, which this script currently doesn't support."
    exit 1
  else
    echo "This is an unknown distro, which this script currently doesn't support."
    exit 1
  fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
  # Install general development environment.
  xcode-select --install

  # Install homebrew for package management.
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

  brew install gnu-getopt

  brew install tmux
fi
