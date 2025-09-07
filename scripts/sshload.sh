function sshload() {
    if [ -z "$1" ]; then
        echo " "
        echo "Usage: sshload <keyname>"
        echo "  Example: sshload depadmin"
        echo " "
        return 1
    fi

    local keyfile="$HOME/.ssh/$1"

    if [ ! -f "$keyfile" ]; then
        echo "Key not found: $keyfile"
        return 1
    fi

    #echo "Initializing keychain for: $keyfile"
    echo " "
    eval "$(keychain --quiet --eval "$keyfile")"

    # Check if the key is already loaded
    if ssh-add -l | grep -q "$(ssh-keygen -lf "$keyfile" | awk '{print $2}')"; then
        echo "Key already loaded: $keyfile"
    else
        echo "Adding key to agent: $keyfile"
        ssh-add "$keyfile"
    fi

    echo " "
    echo "Current keys:"
    echo "-------------"
    ssh-add -l
    echo " "
}

sshload "$@"
