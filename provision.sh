#!/bin/bash

pushd .
sudo apt update && sudo apt upgrade -y
cd ~/Code/baseline
cp bash_aliases ~/.bash_aliases

bash baseline-utilities.sh
bash baseline-git.sh
bash baseline-app-frameworks.sh
bash baseline-sshd.sh
bash app-veracrypt.sh
bash app-brave.sh
popd