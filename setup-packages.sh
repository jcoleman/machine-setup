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

    sudo apt-get install -y vim tmux

    # Install general development environment.
    if [[ `apt-cache search linux-tools-generic` == "" ]]; then
      sudo apt-get install -y linux-tools
    else
      sudo apt-get install -y linux-tools-generic
    fi
    sudo apt-get install -y git build-essential gdb patch

    # Postgres dev dependencies.
    # Original commands from: https://blog.2ndquadrant.com/testing-new-postgresql-versions-without-messing-up-your-install/
    sudo apt-get -y install flex zlib1g-dev # libreadline-dev
    sudo apt-get -y build-dep postgresql
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
fi
