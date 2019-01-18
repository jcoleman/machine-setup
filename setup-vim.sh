#!/bin/bash

ln -sf $PWD/vimrc.bundles.local $HOME/.vimrc.bundles.local
ln -sf $PWD/vimrc_local $HOME/.vimrc_local
vim +PlugInstall +PlugUpdate +PlugClean +qall
