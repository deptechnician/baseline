
# Usage
#  $1 = the command that launches the app (eg org.onlyoffice.desktopeditors)
#  $2 = a friendly name (eg "Only Office Desktop")
#
#  Most of the time, 1 and 2 are the same.

flatpak info "$1" > /dev/null 2>> /dev/null
if [ $? -eq 0 ]
then 
    echo "$2 is already installed"
else   
    echo "Installing $2"
    #flatpak install --user "$1" -y >> ~/.provision.log
    sudo flatpak install flathub "$1" -y >> ~/.provision.log
fi

