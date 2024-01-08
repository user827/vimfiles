#!/bin/bash

msg() {
  log info "$@"
}

error() {
  log error "$1"
  exit "${2:-1}"
}

warn() {
  log warn "$@"
}

warn_failed() {
  log warn "failed: $*"
}

log_prefix() {
  if [ -n "$1" ]; then
    g_log_prefix="$1: "
  else
    g_log_prefix=
  fi
}

log() {
  local prefix color='' nl='\n'
  if [ "$1" = -n ]; then
    nl=
    shift
  fi
  case "$1" in
    info)
      prefix='-- '
      color='32'
      ;;
    notice)
      prefix='-- '
      color='33'
      ;;
    warn)
      prefix='W- '
      color='31'
      ;;
    error)
      prefix='E- '
      color='31'
      ;;
  esac
  shift
  prefix="$prefix${g_log_prefix:-}"
  if [ -n "$color" ]; then
    printf "\033[${color}m%s\033[0m$nl" "$prefix$*" >&2
  else
    printf "%s$nl" "$prefix$*" >&2
  fi
}


link_verbose() {
  local target="$1" dst="$2"
  Lln "$target" "$dst" verb
}

Ltmpdir() {
  _RET="$(mktemp -d --tmpdir home.XXXXXXXXXXXXX)"
}

Ltmp() {
  _RET="$(mktemp --tmpdir home.XXXXXXXXXXXXX)"
}


prepare_gen() {
  local src="$1" dstname="$2" perm="$3"
  shift 3
  sed "$@" "$src" > "$dstname"
  chmod "$perm" "$dstname"
}

install_file() {
  local "src=$1" "dst=$2" ans=
  local verbose="${3:-yes}"

  if [ -h "$src" ]; then
    [ -h "$dst" ] && [ "$(readlink -- "$dst")" = "$(readlink -- "$src")" ] && return 0
  else
    if [ ! -h "$dst" ]; then
      if [ -f "$dst" ]; then
        cmp -s -- "$src" "$dst" && return 0
      elif [ -d "$dst" ]; then
        [ -n "${BATCH:-}" ] || read -rp"replace directory '$dst'? " ans
        if [ -z "${BATCH:-}" ] && [ "$ans" != y ]; then
          warn skipping
          return 0
        fi
        mv -T --backup=numbered -- "$dst" "$dst".old
      fi
    fi
  fi
  if [ -h "$dst" ] || [ -e "$dst" ]; then
    [ -n "${BATCH:-}" ] || read -rp"overwrite '$dst'? " ans
    if [ -z "${BATCH:-}" ] && [ "$ans" != y ]; then
      warn "skipping"
      return 0
    else
      rm --interactive=never -- "$dst"
    fi
  fi
  [ "$verbose" != silent ] && msg "Install: $dst"
  cp -diT --remove-destination --backup=numbered -- "$src" "$dst"
}

Lln() {
  local src="$1" dst="$2" dstdir='' linksrc='' ans=''
  local verbose="${3:-yes}"
  # in case some of the directories are symbolic links
  dstdir=$(readlink -m -- "$(dirname -- "$dst")")
  linksrc=$(realpath -m -s --relative-to "$dstdir" -- "$src")

  #TODO do something with a broken link?
  #if [ -h "$dst" ] && [ ! -e "$dst" ]; then
  #fi
  if [ -h "$dst" ] && [ "$(readlink -- "$dst")" = "$linksrc" ]; then
    return 0
  elif [ -d "$dst" ]; then
    if [ "$OPT_FORCE" != true ]; then
      [ -n "${BATCH:-}" ] || read -rp"replace directory '$dst'? " ans
      if [ -z "${BATCH:-}" ] && [ "$ans" != y ]; then
        warn skipping
        return 0
      fi
    fi
    mv -T --backup=numbered -- "$dst" "$dst".old
  elif [ -h "$dst" ] || [ -e "$dst" ]; then
    if [ "$OPT_FORCE" != true ]; then
      [ -n "${BATCH:-}" ] || read -rp"overwrite '$dst'? " ans
      if [ -z "${BATCH:-}" ] && [ "$ans" != y ]; then
        warn skipping
        return 0
      fi
    fi
    mv --backup=numbered -- "$dst" "$dst".old
  fi
  [ "$verbose" != silent ] && msg "Linking: $dst"
  ln -siT --backup=numbered -- "$linksrc" "$dst"
}

run_module() {
  _RET=0
  local _action="$1" _path="$2" _oldsetopts errfile="$3" count
  module=${_path##*/}
  module=${module%.sh}
  # does not check other functions though
  if is_func "$_action"; then
    log error "function $_action already exists"
    return 1
  fi
  (
  . "$_path"
  is_func "$_action" || return 0
  log notice "$_action: $module"
  log_prefix "$module"
  _oldsetopts=$-
  set +e
  ( set -"$_oldsetopts"; "$_action" )
  _RET=$?
  set -"$_oldsetopts"
  log_prefix ""
  if [ "$_RET" != 0 ]; then
    log warn "$module failed"
    read -r count < "$errfile"
    count=$((count + 1))
    echo "$count" > "$errfile"
  fi
  )
}

run_modules() {
  local moddir="$1" modname="$2" f errfile errs
  errfile=$(mktemp --tmpdir)
  echo 0 > "$errfile"
  for f in "$moddir"/*.sh; do
    run_module "$modname" "$f" "$errfile"
  done
  read -r errs < "$errfile"
  if [ "$errs" -gt 0 ]; then
    log warn "module $modname: had $errs errors!"
  else
    log notice "module $modname: all ok!"
  fi
  rm -- "$errfile"
}

is_func() {
  [ "$(type -t -- "$1")" = "function" ]
}
