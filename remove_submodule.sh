#!/bin/bash
set -eu

# TODO does nmot work when used inside a submodule

GITROOT="$(git rev-parse --show-toplevel)"
MODULE_META_PATH="$GITROOT/.git/modules"
GITCONFIG=$GITROOT/.git/config
while [ ! -f "$GITROOT/.git/config" ];  do
  echo 'in a submodule'
  name=$(basename "$GITROOT")
  GITROOT="$(git -C "$GITROOT"/.. rev-parse --show-toplevel)"
  GITCONFIG=$GITROOT/.git/modules/$name/config
  MODULE_META_PATH="$GITROOT/.git/modules/$name/modules"
  if [ ! -f "$GITCONFIG" ] || [ ! -d "$MODULE_META_PATH" ] ; then
    echo 'dunno what to do'
    exit 1
  fi
done

FORCE=

exists_modules() {
  local exists
  exists=$(git config --file=.gitmodules submodule."$1".url) || return 1
  test -n "$exists"
}

exists_config() {
  local exists
  exists=$(git config --file="$GITCONFIG" submodule."$1".url) || return 1
  test -n "$exists"
}

remove() {
  local path force="$FORCE"

  path=$1
  if ! [[ "$(readlink -f "$path")" = $GITROOT/* ]]; then
    echo "not in gitroot $path"
    return 1
  fi

  if ! exists_modules "$path" && ! exists_config "$path"; then
    read -p"Not in git records. Try to cleanup anyway? ($path) [y/N]" ans
    if [ "$ans" = y ]; then
      force=--force
    else
      return 0
    fi
  else
    read -rp"Remove $path ${FORCE:+(forced)}? [y/N]" ans
    [ "$ans" = y ] || return 0
  fi

  echo Removing cached entry and from the working tree
  if ! git rm "$force" "$path" && [ -z "$force" ]; then
    return 1
  fi
  if [ -f "$path" ] || [ -d "$path" ]; then
    echo Removing leftover path
    rm -r --interactive=never "$path"
  fi

  echo Trying to remove sections
  exists_modules "$path" &&  { git config -f .gitmodules --remove-section submodule."$path" || true; }
  exists_config "$path" &&  { git config -f "$GITCONFIG" --remove-section submodule."$path" || true; }

  local dir oldpwd="$PWD"
  echo Removing module meta
  if [ -d "$MODULE_META_PATH/$path" ]; then
    cd "$MODULE_META_PATH/$path"/..
    rm -r --interactive=never "${MODULE_META_PATH:?}/$path"
    echo Removing empty path components
    while [ "$PWD" != "$MODULE_META_PATH" ]; do
      [ "$(ls -A "$PWD")" = "" ] || break
      dir=$PWD
      cd ..
      rmdir -v "$dir"
    done
  fi
  cd "$oldpwd"
}

case "$1" in
  --force)
    FORCE=$1
    shift
    ;;
  --*)
    echo unknown option "$1"
    exit 1
    ;;
esac

for arg; do
  remove "$arg"
done
