# Syncup command - uploads the current folder to a destination folder such that the destination mirrors the current>
function syncup() {
    if [ -z "$1" ]; then
        echo " "
        echo "Usage: syncup [destination]"
        echo " "
        echo "Uploads the content from the current folder and mirrors it into a destination folder"
        echo " "
        echo "Example: syncup family@familynas.local:/nas"
        echo " "
    else
        rsync -avz --progress --delete --no-group ./ "$1"
    fi
}

syncup "$@"
