# Displays reference material, like cliff notes for man pages
function ref() {
    local filename="$HOME/Code/dep/provision/linux/reference/$1.sh"

    if [ -z "$1" ]; then
        echo " "
        echo "Usage: ref [topic]"
        echo " "
        echo "You can pick from the following topics"
        echo "--------------------------------------"
        find $HOME/Code/dep/provision/linux/reference -maxdepth 1 -type f -exec basename {} \; | sed 's/\.[^.]*$//'
        echo " "
    else
        cat $filename
    fi
}

ref "$@"
