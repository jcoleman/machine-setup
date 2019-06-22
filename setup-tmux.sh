#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$DIR/get-clone-directory.sh"

CLONE_DIRECTORY="$(get-clone-directory)"

tmux new-window -n "postgres"
tmux split-window -v
tmux select-pane -t 0
tmux send-keys -t 0 "cd $CLONE_DIRECTORY/postgres; vim" C-m
tmux send-keys -t 1 "cd $CLONE_DIRECTORY/postgres" C-m
tmux send-keys -t 1 "export PATH=$CLONE_DIRECTORY/postgresql-test/bin:\$PATH" C-m
tmux send-keys -t 1 "export PGHOST=localhost" C-m
tmux send-keys -t 1 "export PGPORT=5444" C-m

tmux new-window -n "test-postgres"
tmux split-window -h
tmux select-pane -t 0
tmux send-keys -t 0 "cd $CLONE_DIRECTORY/postgres" C-m
tmux send-keys -t 1 "cd $CLONE_DIRECTORY/postgres-dev-tools" C-m
