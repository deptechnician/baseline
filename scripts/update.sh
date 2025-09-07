
# -------------------------------------
# Aliases os update function
# -------------------------------------
function update() {
    if command -v apt >/dev/null 2>&1; then
        echo "==> Updating & upgrading (Ubuntu/Debian)..."
        sudo apt update -y
        sudo apt upgrade -y

    elif command -v pacman >/dev/null 2>&1; then
        echo "==> Updating & upgrading (Arch)..."
        sudo pacman -Syu --noconfirm

    elif command -v dnf >/dev/null 2>&1; then
        echo "==> Updating & upgrading (Fedora/Red Hat)..."
        sudo dnf upgrade -y

    else
        echo "No supported package manager found (apt, pacman, dnf)."
        exit 1
    fi

    echo "✅ Update complete."
}

update "$@"
