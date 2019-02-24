#!/bin/bash

if [[ ! -d "$HOME/.vim" ]]; then
  git clone git@github.com:braintreeps/vim_dotfiles "$HOME/.vim"
  ~/.vim/activate.sh
else
  echo "Already installed vim_dotfiles; if you want to update please run:"
  echo "  pushd ~/.vim; git pull; ./activate.sh; popd"
fi

ln -sf $PWD/bash_profile $HOME/.bash_profile
ln -sf $PWD/tmux.conf $HOME/.tmux.conf
ln -sf $PWD/gitconfig $HOME/.gitconfig
