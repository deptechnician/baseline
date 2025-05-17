#!/bin/bash

echo "------------------------------------------------------------------------"
echo " SSH Server"
echo "------------------------------------------------------------------------"

if systemctl is-active --quiet sshd; then
    echo "SSHD is already configured and running"
else
    # Install the ssh server
    #
    sudo apt update && sudo apt upgrade -y
    sudo apt install openssh-server -y

    # Setup authorized keys
    # ---------------------
    mkdir ~/.ssh
    touch ~/.ssh/authorized_keys
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/authorized_keys
    cat ~/.ssh/authorized_keys
fi

echo "Completed SSH Server configuration"
echo " "

