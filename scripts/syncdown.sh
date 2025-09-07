# Syncdown command - uploads the current folder to a destination folder such that the destination mirrors the curre>
function syncdown() {   
    if [ -z "$1" ]; then
        echo " "
        echo "Usage: syncdown [source]"
        echo " "
        echo "Downloads the content from a source folder and mirrors it into the current folder"
        echo " "
        echo "Example: syncdown family@familynas.local:/nas"
        echo " "
    else
        rsync -avz --progress --delete --no-group "$1" ./
    fi
}

syncdown "$@"
