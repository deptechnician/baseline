# Usage
#  $1 = the command that launches the app
#  $2 = the name of the package, sudo apt install <package>
#  $3 = a friendly name
#
#  Most of the time, 1 and 2 are the same.


if command -v "$1" > /dev/null 2> /dev/null
then
    echo "$3 is already installed"
else
    echo "Installing $3..."
    sudo apt install "$2" -y >> ~/.provision.log 2>> ~/.provision.log
fi