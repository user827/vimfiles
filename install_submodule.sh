#!/bin/sh
set -eu

url=$1
name=${1%.git}
name=${name%.vim}
name=${name%.nvim}
name=${name##*/}
git submodule add --name "$name" "$url" vim/pack/light/opt/"$name"

#vim "+helptags ALL" +q
#nvim "+helptags ALL" "+UpdateRemotePlugins" +q
nvim -u NONE -N "+packadd $name | packadd vim-pathogen | call pathogen#helptags() | quit"
echo "Run UpdateRemotePlugins if necessary"
