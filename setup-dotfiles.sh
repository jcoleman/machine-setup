#!/usr/bin/env bash

if [[ ! -d "$HOME/.vim" ]]; then
  git clone git@github.com:braintreeps/vim_dotfiles "$HOME/.vim"
  ~/.vim/activate.sh
else
  echo "Already installed vim_dotfiles; if you want to update please run:"
  echo "  pushd ~/.vim; git pull; ./activate.sh; popd"
fi

ln -sf $PWD/bash_profile $HOME/.bash_profile
ln -sf $PWD/bashrc_local $HOME/.bashrc_local
if [ ! -f $HOME/.bashrc ]; then
  touch $HOME/.bashrc
fi
if ! grep -q "^source $HOME/.bashrc_local" $HOME/.bashrc; then
  echo "" >> $HOME/.bashrc
  echo "source $HOME/.bashrc_local" >> $HOME/.bashrc

fi
ln -sf $PWD/tmux.conf $HOME/.tmux.conf
ln -sf $PWD/gitconfig $HOME/.gitconfig
