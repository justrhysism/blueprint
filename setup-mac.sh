#!/usr/bin/env bash
#
# Setup Mac
# Idempotent setup scripts

set -e

# macOS development setup
#
# Run this script to install and setup basic tools on a machine.
# Or run it to update current setup to latest changes.
# Steal the bits you like and adjust it to your needs.

# Run in dotfiles folder
pushd "$(dirname "${BASH_SOURCE}")"

# Imports
. ./config.sh
. ./utils.sh

# Become super user before starting work
printf "Require super-user for setup.\n"
sudo -v


printf "\nSetting up system with latest toys ...\n\n"


# Enable italic support
#tic xterm-256color-italic.terminfo

#region Directories Setup
# Create folders
mkdir -p \
  ${HOME}/bin \
  ${HOME}/Projects

# Show Hidden Directories
setfile -a v ~/Desktop
chflags nohidden ~/Desktop

# setfile -a v ~/Library
# chflags nohidden ~/Library
#endregion


#region Create Symlinks

link_dotfile gitconfig

#endregion

#region macOS and Xcode
#printf "\nUpdating macOS\n" - Don't update automatically as we need to run fix script after a restart
# sudo softwareupdate -i -a

if [[ "$(xcode-select -p)" == "" ]]; then
  printf "\nInstalling Xcode\n"
  xcode-select --install
fi
#endregion

#region Brew
if ! command -v brew > /dev/null 2>&1; then
  printf "\nInstalling Brew\n"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
#  brew analytics off
fi

printf "\nUpdating Brew\n"
brew bundle install --cleanup

# FZF - Install key bindings and fuzzy completion
$(brew --prefix)/opt/fzf/install \
  --no-update-rc \
  --key-bindings \
  --completion
#endregion

#region Post Brew Install

#region Setapp
# Run Setapp Installer if Setapp isn't installed
if [ ! -d "/Applications/Setapp.app" ]; then
  SETAPP_CASK_PATH="$(brew info --cask setapp | sed -n 3p | tr ' ' '\n' | head -1)"
  SETAPP_INSTALLER="$(brew info --cask setapp --json=v2 | jq ".casks[0].artifacts[1].path")"
  SETAPP_INSTALLER_PATH="${SETAPP_CASK_PATH}/${SETAPP_INSTALLER}"

  open "${SETAPP_INSTALLER_PATH}"
fi
#endregion

#endregion

#region Packages

# NPM packages
#printf "\nUpdating npm packages\n"
#cat npm.txt | xargs npm i -g
#ls /usr/local/lib/node_modules > npm.txt

#endregion

#region Application Config

# 1Password Signin
eval $(op signin my); # TODO: Setup 1P to handle new machine use case

# Alfred
defaults write com.runningwithcrayons.Alfred-Preferences syncfolder "~/Documents/Application Files/Alfred"

# iTerm2
defaults write com.googlecode.iterm2 PrefsCustomFolder "~/Documents/Application Files/iTerm"

# Rectangle
defaults write com.knollsoft.Rectangle launchOnLogin -bool true

# Choosy
defaults write com.choosyosx.Choosy launchAtLogin -bool true
defaults write com.choosyosx.Choosy displayMenuBarItem -bool false

CHOOSY_LIB_DIR="~/Library/Application Support/Choosy"
mkdir -p "${CHOOSY_LIB_DIR}"

if [[ ! -f "${CHOOSY_LIB_DIR}/.key" ]]; then
  op get item Choosy --fields reg_email,reg_code --format csv | sed "s/,/\//" > .key

#endregion

#region Set Defaults

# Browser
brew install defaultbrowser && defaultbrowser choosy && brew uninstall defaultbrowser

#endregion

#region Start Applications

# Open 1Password and hide
open "/Applications/1Password 7.app" --hide --background
osascript -e 'quit app "1Password 7"' > /dev/null 2>&1

open "/Applications/Alfred 4.app"

open "/Applications/Rectangle.app"
#open "/Applications/Setapp.app" --hide --background
open "/Applications/OneDrive.app" --hide --background

# Open Choosy and hide preferences
open "/Applications/Choosy.app"

# TODO: Figure out how to request Security > Privacy > A11y 
osascript <<END
  set timeoutSeconds to 2.000000
  set uiScript to "click UI Element 15 of window \"Choosy\" of application process \"Choosy\""
  my doWithTimeout( uiScript, timeoutSeconds )

  on doWithTimeout(uiScript, timeoutSeconds)
    set endDate to (current date) + timeoutSeconds
    repeat
      try
        run script "tell application \"System Events\"
  " & uiScript & "
  end tell"
        exit repeat
      on error errorMessage
        if ((current date) > endDate) then
          error "Can not " & uiScript
        end if
      end try
    end repeat
  end doWithTimeout
END

#endregion

popd
printf "\n\n\nAll good. Enjoy your day human.\n"
