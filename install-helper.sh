# Usage
#  $1 = the package to install
#
#  Most of the time, 1 and 2 are the same.
if command -v "$1" > /dev/null 2>&1; then
    echo "$1 is already installed"
else
    echo "Installing $1..."
    if command -v apt >/dev/null 2>&1; then
        # Ubuntu / Debian
        sudo apt update -y
        sudo apt install -y "$1"
    elif command -v pacman >/dev/null 2>&1; then
        # Arch Linux
        sudo pacman -Sy --noconfirm "$1"
    else
        echo "No supported package manager found. Please install $1 manually."
    fi
fi
