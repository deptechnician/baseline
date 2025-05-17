#!/bin/bash

echo "------------------------------------------------------------------------"
echo " Git configuration"
echo "------------------------------------------------------------------------"

#if [[ -f ~/.ssh/depgithub ]]; then
#    echo "Git is already provisioned"
#else
# echo " "
#fi

git config --global user.name DepTech
git config --global user.email technician@dep

#echo "Add this key to your github account:"
#cat ~/.ssh/depgithub.pub

echo "Completed git configuration"
echo " "


#ssh-keygen -t ed25519 -C "depgithub" -f ~/.ssh/depgithub
#eval "$(ssh-agent -s)"
#ssh-add ~/.ssh/depgithub
