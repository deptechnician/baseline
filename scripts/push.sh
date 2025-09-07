# Sendup command - uploads the current folder to a destination without mirroring it.
function push() {
    if [ -z "$1" ]; then
        echo " "
        echo "Usage: push [destination]"
        echo " "
        echo "Uploads the content from the current folder into the dest folder"
        echo " "
        echo "Example: push family@familynas.local:/nas"
        echo " "
    else
        rsync -avz --progress --no-group ./ "$1"/
    fi
}

push "$@"
