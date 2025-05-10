#!/bin/bash

pushd .
sudo apt update && sudo apt upgrade -y
cd ~/Code/baseline
cp bash_aliases ~/.bash_aliases

bash baseline-utilities.sh
bash baseline-app-frameworks.sh
bash dep-sshd.sh
popd