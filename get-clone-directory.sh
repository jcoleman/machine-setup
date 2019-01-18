#!/bin/bash

function get-clone-directory {
  CLONE_DIRECTORY="$HOME/Source"
  if [[ ! -d "$CLONE_DIRECTORY" ]]; then
    CLONE_DIRECTORY=$HOME
  fi
  echo "$CLONE_DIRECTORY"
}
