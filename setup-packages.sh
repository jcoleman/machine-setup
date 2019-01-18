if [[ "$OSTYPE" == "linux-gnu" ]]; then
  if [ -f /etc/debian_version ]; then
    sudo aptitude update -y

    # Install general development environment.
    sudo aptitude install -y git build-essential gdb linux-tools patch

    # Postgres dev dependencies.
    sudo aptitude -y flex build-dep postgresql
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
