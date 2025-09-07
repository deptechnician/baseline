# Pull down content from the nas to the current directory
function hostchange() {
    # Ensure a new hostname is provided
    if [ -z "$1" ]; then
        echo "Usage: changehost <new-hostname>"
    else
        NEW_HOSTNAME="$1"

        # Set the new hostname using hostnamectl
        hostnamectl set-hostname "$NEW_HOSTNAME"

        # Update /etc/hosts entry for 127.0.1.1
        sudo sed -i "s/^\(127\.0\.1\.1\s\+\).*$/\1$NEW_HOSTNAME/" /etc/hosts

        # Confirm the change
        echo "Hostname changed to: $NEW_HOSTNAME"
        echo "You should reboot to fully apply changes."
    fi
}

hostchange "$@"
