#!/usr/bin/env bash
#
# Teardown Mac
#

set -e

# Uninstall Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall.sh)"
