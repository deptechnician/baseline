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

    # Start ssh-agent if not already running or invalid
    if [ -z "$SSH_AUTH_SOCK" ] || ! ssh-add -l >/dev/null 2>&1; then
        echo "Starting new ssh-agent..."
        eval "$(ssh-agent -s)" > /dev/null
        export SSH_AUTH_SOCK SSH_AGENT_PID
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
