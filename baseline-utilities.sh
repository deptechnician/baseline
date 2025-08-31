#!/bin/bash

echo "------------------------------------------------------------------------"
echo " Utilities"
echo "------------------------------------------------------------------------"

# Update OS to start clean
echo "Updating OS..."
sudo apt update && sudo apt upgrade -y

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
  tree
  vim
  wget
  xclip
  wakeonlan
  zoxide
)

# Loop through and install each package
for utility in "${utilities[@]}"; do
  bash helper-apt.sh "$utility" "$utility" "$utility"
done

echo "All utilities have been installed."
echo " "

