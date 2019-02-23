#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$DIR/get-clone-directory.sh"

declare -a REPOS=(
  "postgres"
  "postgres-dev-tools"
  "machine-setup"
)

CLONE_DIRECTORY="$(get-clone-directory)"

pushd "$CLONE_DIRECTORY"
for repo in "${REPOS[@]}"
do
  echo "Updating jcoleman/$repo"
  if [[ ! -d "$repo" ]]; then
    git clone "git@github.com:jcoleman/$repo.git"
  else
    pushd $repo
    git pull --ff-only
    popd
  fi
done
popd

pushd $CLONE_DIRECTORY/postgres
! git remote | grep postgres
if [[ ${PIPESTATUS[0]} -eq 0 ]]; then
  git remote add postgres git://git.postgresql.org/git/postgresql.git
fi
git fetch
./configure --prefix=$CLONE_DIRECTORY/postgresql-test --enable-cassert --enable-debug --enable-depend CFLAGS="-ggdb -Og -g3 -fno-omit-frame-pointer -DOPTIMIZER_DEBUG"
make clean
ln -sf "$CLONE_DIRECTORY/postgres-dev-tools/lvimrc" "$CLONE_DIRECTORY/postgres/.lvimrc"
popd
