#!/usr/bin/env bash
#
# Utils
#

# Imports
. ./config.sh

pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

log () {
  if [ "$FLAG_QUIET" != true ]; then 
    if [ "$FLAG_VERBOSE" == true ]; then command printf "\n"; fi
    command printf "$@"
    command printf "\n"
  fi
}

verbose () {
  if [ "$FLAG_VERBOSE" == true ]; then
    command printf "$@"
    command printf "\n"
  fi
}

warn () {
  command printf "WARNING:"; command printf "$@"; command printf "\n"
}

link_to() {
    if [ ! -e "$1" ]; then
      warn "cannot link %s because it does not exist" "$1"
    else
      if [ -n "$2" ]; then
        rm -f "$2"
        ln -s "$1" "$2"
        verbose "Linked %s -> %s" "$1" "$2"  
      else
        warn "missing target to link %s (%s)" "$1" "$2"
      fi
  fi
}

link_dotfile() {
  link_to "$BLUEDIR${2:+/$2}/$1" "$HOME/${3:-${1:+.$1}}"
}

link_dotfile_dir() {
  local targetDir="$BLUEDIR/$1/*"

  for file in $targetDir; do
    if [[ $file != *.md ]]; then
      link_dotfile "$(basename "$file")" "$1" ""
    fi
  done
}

