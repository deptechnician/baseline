# Pull down content from the nas to the current directory
function sshnas() {
    NAS_FILE=$HOME/.dep/nas.conf
    if [ -f "$NAS_FILE" ]; then
        source "$NAS_FILE"
        echo ""
        echo "$NAS_ADDRESS"
        echo "$NAS_PATH"
        ssh $NAS_USER@$NAS_ADDRESS
    else
        echo "Cannot find configuration file $NAS_FILE"
    fi
}

sshnas "$@"
