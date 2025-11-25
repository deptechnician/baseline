#!/bin/bash

echo "------------------------------------------------------------------------"
echo " Utilities"
echo "------------------------------------------------------------------------"

# Define an array of packages
utilities=(
  avahi-utils
  btop
  curl
  find
  fzf
  git
  keychain
  lm-sensors
  make
  nmap
  nano
  tmux
  tpm2-tools
  tree
  vim
  wget
  xclip
  wakeonlan
  zoxide
)

# Loop through and install each package
for utility in "${utilities[@]}"; do
  bash install-helper.sh "$utility"
done

echo "All utilities have been installed."
echo " "

