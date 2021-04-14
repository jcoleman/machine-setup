#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$DIR/get-clone-directory.sh"

declare -A REPOS
REPOS["postgres"]="jcoleman"
REPOS["postgres-dev-tools"]="jcoleman"
REPOS["machine-setup"]="jcoleman"
if [[ "$CPAIR" -ne 1 ]]; then
  REPOS["bash-git-prompt"]="magicmonty"
fi

CLONE_DIRECTORY="$(get-clone-directory)"

! HAS_LOCAL_OR_FORWARDED_SSH_KEY=$(grep jtc331@gmail.com "$HOME/.ssh/id_rsa.pub" || ssh-add -L | grep -E "j(ame)?coleman")
! USE_SSH_FOR_GIT=${PIPESTATUS[0]}
pushd "$CLONE_DIRECTORY"
for repo in "${!REPOS[@]}"; do
  user=${REPOS["$repo"]}
  echo "Cloning $user/$repo"
  if [[ ! -d "$repo" ]]; then
    if [[ "$USE_SSH_FOR_GIT" -eq 0 ]]; then
      git clone "git@github.com:$user/$repo.git"
    else
      git clone "https://github.com/$user/$repo.git"
    fi
  else
    pushd $repo
    echo "Updating $user/$repo"
    git pull --ff-only
    popd
  fi
done
popd

pushd $CLONE_DIRECTORY/postgres
! HAS_POSTGRES_REMOTE=$(git remote | grep postgres)
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
  git remote add postgres git://git.postgresql.org/git/postgresql.git
  ./configure --prefix=$CLONE_DIRECTORY/postgresql-test --enable-cassert --enable-debug --enable-depend CFLAGS="-ggdb -Og -g3 -fno-omit-frame-pointer -DOPTIMIZER_DEBUG"
  make clean
fi
git fetch
if [[ ! -f $CLONE_DIRECTORY/postgres/.lvimrc ]]; then
  ln -sf "$CLONE_DIRECTORY/postgres-dev-tools/lvimrc" "$CLONE_DIRECTORY/postgres/.lvimrc"
fi
! HAS_LVIMRC_EXCLUDE=$(grep -E --silent '^\.lvimrc$' $CLONE_DIRECTORY/postgres/.git/info/exclude)
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
  echo ".lvimrc" >> $CLONE_DIRECTORY/postgres/.git/info/exclude
fi
git config core.pager 'less -x1,5'
popd
