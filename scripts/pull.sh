# Sendup command - uploads the current folder to a destination without mirroring it.
function pull() {
    if [ -z "$1" ]; then
        echo " "
        echo "Usage: pull [destination]"
        echo " "
        echo "Downloads the content from the destination to the current folder"
        echo " "
        echo "Example: pull family@familynas.local:/nas"
        echo " "
    else
        rsync -avz --progress --no-group "$1"/ ./
    fi
}

pull "$@"
