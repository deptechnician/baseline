# Installs an individual module
function provision() {
    local filename="$HOME/Code/dep/provision/linux/install/$1.sh"

    if [ -z "$1" ]; then
        echo " "
        echo "Usage: provision [module]"
        echo " "
        echo "You can pick from the following modules"
        echo "--------------------------------------"
        find $HOME/Code/dep/provision/linux/install -maxdepth 1 -type f -exec basename {} \; | sed 's/\.[^.]*$//'
        echo " "
    else
        pushd .
        cd $HOME/Code/dep/provision/linux
        bash "install/$1.sh"
        popd
    fi
}

provision "$@"

