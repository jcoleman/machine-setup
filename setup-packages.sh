#!/usr/bin/env bash

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
      apt-transport-https \
      ca-certificates \
      gnupg-agent \
      software-properties-common \
      colordiff \
      python-pip \
      postgresql-client-common \
      postgresql-client-10 \
      postgresql-common \
      postgresql-server-dev-10 \
      libpq-dev \
      openssh-server \
      ruby-dev \
      ruby-bundler \
      nmap \
      lld \
      # End apt-get install.

    sudo gem install bundler

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
    # For Postgres code coverage.
    sudp apt-get -y install lcov
    # To run Postgres `make check world`.
    sudo apt-get -y install xsltproc libxml2-utils
    sudo apt-get -y build-dep postgresql
    # For Postgres code style formatting.
    sudo apt-get -y install \
      libedit-devel \
      libxml2-dev \
      libxslt-dev \
      libpam-dev \
      libssl-dev \
      libselinux-dev \
      libkrb5-dev \
      # End apt-get install.

    ! ANSIBLE_PPA_INSTALLED=$(grep -q "^deb .*ansible/ansible" /etc/apt/sources.list /etc/apt/sources.list.d/*)
    if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
      sudo apt-add-repository --yes --update ppa:ansible/ansible
      sudo apt-get -y install ansible
    fi
    pip install jmespath

    pip install -U platformio

    if [[ "$CPAIR" -ne 1 ]]; then
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

      ! ONEPASSWORD_KEYRING_INSTALLED=$(ls /usr/share/keyrings/1password-archive-keyring.gpg)
      if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
        curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
      fi

      ! ONEPASSWORD_APT_SOURCE_INSTALLED=$(ls /etc/apt/sources.list.d/1password.list)
      if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
        echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | sudo tee /etc/apt/sources.list.d/1password.list
      fi

      ! ONEPASSWORD_DEBSIG_POLICY_INSTALLED=$(ls /etc/debsig/policies/AC2D62742012EA22/1password.pol)
      if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
        sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
        curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
        sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
        curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
      fi

      sudo apt update && sudo apt-get -y install 1password
    fi

    # Install Yarn/Node.
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    sudo apt-get update && sudo apt-get install -y yarn

    # Install Docker.
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs -u || lsb_release -cs) stable"
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker $USER

    # Install Docker compose.
    if [[ ! -f /usr/local/bin/docker-compose ]]; then
      sudo curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
      sudo chmod +x /usr/local/bin/docker-compose
    fi

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
  sudo mkdir -p /opt/bin

  # Install general development environment.
  xcode-select --install || true

  # Install homebrew for package management.
  ! BREW_INSTALLED=$(which brew)
  if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/jamecoleman/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi

  ! GNU_GETOPT_INSTALLED=$(brew list | grep gnu-getopt)
  if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    brew install gnu-getopt
  fi

  ! TMUX_INSTALLED=$(which tmux)
  if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    brew install tmux
  fi

  ! UPDATED_BASH_INSTALLED=$(grep /opt/homebrew/bin/bash /etc/shells)
  if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    sudo bash -c 'echo /opt/homebrew/bin/bash >> /etc/shells'
    brew install bash
    chsh -s /opt/homebrew/bin/bash
  fi

	brew install \
		rbenv \
		ruby-build \
		icu4c \
		colordiff \
		libpqxx \
		automake \
		libtool \
		autoconf \
		autoconf-archive \
		pkg-config \
		# End brew install

	sudo cpan local::lib
	sudo cpan IPC::Run
fi

cpan SHANCOCK/Perl-Tidy-20230309.tar.gz
