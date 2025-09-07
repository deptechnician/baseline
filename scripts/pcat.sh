# Shows the provisioning script for an individual module
function pcat() {  
    local filename="$HOME/Code/dep/provision/linux/install/$1.sh"

    if [ -z "$1" ]; then
        echo " "
        echo "Usage: pcat [module]"
        echo " "
        echo "You can pick from the following modules"
        echo "--------------------------------------"
        find "$HOME"/Code/dep/provision/linux/install -maxdepth 1 -type f -exec basename {} \; | sed 's/\.[^.]*$//'
        echo " "
    else
        pushd .
        cd "$HOME"/Code/dep/provision/linux
        cat "install/$1.sh"
        popd
    fi
}

pcat "$@"

