function sshload() {
    if [ -z "$1" ]; then
        echo
        echo "Usage: sshload <keyname>"
        echo "  Example: sshload id_rsa"
        echo
        return 1
    fi

    local keyfile="$HOME/.ssh/$1"

    if [ ! -f "$keyfile" ]; then
        echo "Key not found: $keyfile"
        return 1
    fi

    # Check if key is already loaded
    if ssh-add -l 2>/dev/null | grep -q "$(ssh-keygen -lf "$keyfile" | awk '{print $2}')"; then
        echo "Key already loaded: $keyfile"
    else
        echo "Adding key to agent: $keyfile"
        ssh-add "$keyfile"
    fi

    echo
    echo "Current keys:"
    echo "-------------"
    ssh-add -l
    echo
}

sshload "$@"
