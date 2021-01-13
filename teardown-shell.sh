#!/usr/bin/env bash
#
# Teardown Shell
#

set -e

# Remove dotfiles
rm .zshrc

# Remove zinit
rm -rf "${HOME}/.zinit"

# Refresh Shell
exec zsh
