# Usage
#  $1 = the package to install
#
# Usage
#   $1 = the package to install
#
# Note: We check for a command with the same name as the package.
#       If the binary name differs from the package name, adjust accordingly.

if command -v "$1" >/dev/null 2>&1; then
    echo "$1 is already installed"
else
    echo "Installing $1..."
    if command -v apt >/dev/null 2>&1; then
        # Ubuntu / Debian
        sudo apt update -y
        sudo apt install -y "$1"
    elif command -v dnf >/dev/null 2>&1; then
        # Fedora
        sudo dnf -y install "$1"
    elif command -v pacman >/dev/null 2>&1; then
        # Arch Linux
        sudo pacman -Sy --noconfirm "$1"
    else
        echo "No supported package manager found. Please install $1 manually."
        exit 1
    fi
fi
