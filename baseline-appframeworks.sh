#!/bin/bash

echo "------------------------------------------------------------------------"
echo " App frameworks (snap, flatpak) installation"
echo "------------------------------------------------------------------------"


if command -v snap > /dev/null
then
    echo "Snap is already installed"
else
    sudo apt install snapd -y    
fi

if command -v flatpak > /dev/null
then
    echo "Flatpak is already installed"
else
    sudo apt install flatpak -y
fi
sudo apt install gnome-software-plugin-flatpak -y
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "Completed app frameworks installation"
echo " "


