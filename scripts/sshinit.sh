function sshinit() {
    if [ -z "$1" ]; then
        echo " "
        echo "Usage: sshinit <profile>"
        echo "  Example: sshinit melody"
        echo " "
    else
        eval "$(keychain --quiet --agents ssh --eval "$1")"
    fi
}

sshinit "$@"
