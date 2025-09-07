function installapp() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: installapp <package1> [package2] [...]"
        return 1
    fi

    local pkgs=("$@")

    # Detect package manager
    local pm=""
    if command -v apt >/dev/null 2>&1; then
        pm="apt"
        sudo apt update -y
    elif command -v pacman >/dev/null 2>&1; then
        pm="pacman"
        sudo pacman -Sy
    elif command -v dnf >/dev/null 2>&1; then
        pm="dnf"
    elif command -v yum >/dev/null 2>&1; then
        pm="yum"
    else
        echo "No supported package manager found (apt, pacman, dnf, yum)."
        return 1
    fi

    # Install packages in a loop
    for pkg in "${pkgs[@]}"; do
        case "$pm" in
            apt)
                sudo apt install -y "$pkg"
                ;;
            pacman)
                sudo pacman -S --noconfirm "$pkg"
                ;;
            dnf)
                sudo dnf install -y "$pkg"
                ;;
            yum)
                sudo yum install -y "$pkg"
                ;;
        esac
    done
}

installapp "$@"
