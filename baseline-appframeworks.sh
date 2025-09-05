#!/bin/bash

echo "------------------------------------------------------------------------"
echo " App frameworks (snap, flatpak) installation"
echo "------------------------------------------------------------------------"

if command -v flatpak > /dev/null
then
    echo "Flatpak is already installed"
else
    bash install-helper.sh flatpak
fi
bash install-helper.sh gnome-software-plugin-flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "Completed app frameworks installation"
echo " "


