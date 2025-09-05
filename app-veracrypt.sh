#!/bin/bash

echo "------------------------------------------------------------------------"
echo " Download, compile, and install the veracrypt CLI"
echo "------------------------------------------------------------------------"

pushd . > /dev/null

if [[ -f /usr/bin/veracrypt ]]
then
    echo "Veracrypt is already installed"
else
    [[ -d ~/Code ]] || { echo "~/Code directory does not exist. Exiting."; exit 1; }

    # --- Install the pre-requisites
    # --- See compiling guide here: https://www.veracrypt.fr/en/CompilingGuidelineLinux.html
    bash install-helper.sh git git git
    bash install-helper.sh gmake make "make utility"
    bash install-helper.sh g++ g++ "g++ compiler"
    bash install-helper.sh yasm yasm "yasm"
    bash install-helper.sh pkg-config pkg-config "pkg-config"
    bash install-helper.sh libwxgtk3.2-dev libwxgtk3.2-dev "libwxgtk3.2-dev"
    bash install-helper.sh libfuse-dev libfuse-dev "libfuse-dev"
    bash install-helper.sh libpcsclite-dev libpcsclite-dev "libpcsclite-dev"

    # --- Pull the source code
    echo "Cloning Veracrypt repository"
    cd ~/Code >> ~/.provision.log
    git clone https://github.com/veracrypt/VeraCrypt
    [[ -d ~/Code/VeraCrypt ]] || { echo "~/Code/VeraCrypt directory does not exist. Exiting."; exit 1; }

    # --- Compile it
    echo "Compiling veracrypt..."
    cd VeraCrypt/src > /dev/null
    make NOGUI=1

    # --- Install it
    echo "Installing veracrypt..."
    sudo cp Main/veracrypt /usr/bin >> ~/.provision.log
fi

popd > /dev/null

echo "Completed veracrypt installation"
echo " "
