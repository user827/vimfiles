#!/bin/bash

set -eu

cd "$(dirname "$0")"
export L_GIT_ROOT="$PWD"
export L_LIB_PATH="$L_GIT_ROOT"/lib

# Require full paths
vimpath="$HOME/.vim"
nvimpath="$HOME/.config/nvim"
vimdata="$vimpath/LDATA_HEAVY"
modbase="$L_GIT_ROOT"/modules

. "$L_LIB_PATH/install.sh"
OPT_FORCE=false
if [ "${1-}" = --force ]; then
  OPT_FORCE=true
fi

log notice "(Re)Initializing $(basename "$PWD") with:"
msg "vim path in $vimpath"
[ -n "${BATCH:-}" ] || read -rp"press key to continue" ans

if [ -d "$vimpath" ] && ! [ -L "$vimpath" ]; then
  [ -n "${BATCH:-}" ] || read -rp"Old .vim needs to be moved. Press key to back it up." ans
  mv -- "$vimpath" "$vimpath".old.bck
fi
link_verbose "$L_GIT_ROOT/vim" "$vimpath"
link_verbose "$L_GIT_ROOT/vimrc.d" "$HOME"/.vimrc.d
link_verbose "$L_GIT_ROOT/vim" "$nvimpath"



run_modules "$modbase" install

nvim "+helptags ALL | UpdateRemotePlugins | quit"
