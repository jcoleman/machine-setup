#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

ln -sf "$DIR/vimrc.bundles.local" "$HOME/.vimrc.bundles.local"
ln -sf "$DIR/vimrc_local" "$HOME/.vimrc_local"
vim +PlugInstall +PlugUpdate +PlugClean +qall
