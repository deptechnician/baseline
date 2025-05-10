#!/bin/bash

echo "------------------------------------------------------------------------"
echo " Python configuration"
echo "------------------------------------------------------------------------"

bash install/helper-apt.sh pip3 python3-pip "Python3 PIP"
bash install/helper-apt.sh python3.13-venv python3.13-venv "Python3 Virtual Environments"
mkdir ~/.venv
pushd .
cd ~/.venv
python3 -m venv dep
source dep/bin/activate
popd

echo "Completed python configuration"
echo " "