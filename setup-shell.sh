#!/usr/bin/env bash
#
# Setup Shell
#

set -e

usage() {
  cat << EOU
Usage: setup-shell.sh [-vqhf] 

Automatically setup and configure your shell.

Options:
  -h --help
  -f --force    force setup; will delete and re-clone dependencies
  -v --verbose  verbose mode
  -q --quiet    quiet mode
EOU
}

#region Arguments
FLAG_FORCE=false
FLAG_VERBOSE=false
FLAG_QUIET=false
#endregion


# Run in dotfiles folder
pushd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null || exit 1

#region Script Arguments & Help
# See: https://medium.com/@Drew_Stokes/bash-argument-parsing-54f3b81a6a8f
PARAMS=""

while (( "$#" )); do
	# shellcheck disable=SC2221,2222
  case "$1" in
    # -a|--my-boolean-flag)
    #   MY_FLAG=0
    #   shift
    #   ;;
    # -b|--my-flag-with-argument)
    #   if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
    #     MY_FLAG_ARG=$2
    #     shift 2
    #   else
    #     echo "Error: Argument for $1 is missing" >&2
    #     exit 1
    #   fi
    #   ;;

    -f|--force)
      FLAG_FORCE=true
      shift
      ;;

    -v|--verbose)
      FLAG_VERBOSE=true
      shift
      ;;

    -q|--quiet)
      FLAG_QUIET=true
      shift
      ;;

		-h|--help)
			usage
			exit;
			;;

    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
			echo "Pass -h for usage."
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done

# set positional arguments in their proper place
eval set -- "$PARAMS"
#endregion

# Imports
. ./config.sh
. ./utils.sh

#region Setup Bluerc
log "Setup bluerc"
link_dotfile config.sh "" .bluerc
#endregion

#region Link Dotfiles
log "Link Dotfiles"
link_dotfile_dir zsh/runcoms
link_dotfile p10k.zsh zsh/theme
#endregion

#region Znap
log "Znap setup"
# rm -rf "$ZDIR"
mkdir -p "$ZDIR"

pushd "$ZDIR" || exit 1
# TODO: Switch to only cloning if not existing, otherwise get latest
[ ! -d "./zsh-snap" ] && git clone https://github.com/marlonrichert/zsh-snap.git

# shellcheck disable=SC2119
popd || exit
#endregion

# Reload
# shellcheck disable=SC2119
popd || exit
log "\nAll done!"

exec zsh
