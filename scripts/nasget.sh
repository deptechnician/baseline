# Pull down content from the nas to the current directory
function nasget() {
    NAS_FILE=$HOME/.dep/nas.conf
    if [ -f "$NAS_FILE" ]; then
        source "$NAS_FILE"
        echo ""
        echo "$NAS_ADDRESS"
        echo "$NAS_PATH"
        echo "Copying this command to the clipboard: ssh $NAS_USER@$NAS_ADDRESS"
        echo "ssh $NAS_USER@$NAS_ADDRESS" | xclip -selection clipboard
        echo ""
    else
        echo "Cannot find configuration file $NAS_FILE"
    fi
}

nasget "$@"
