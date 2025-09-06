# Usage
#  $1 = the package to install
#
# Usage
#   $1 = the package to install
#
# Note: We check for a command with the same name as the package.
#       If the binary name differs from the package name, adjust accordingly.


pkg="$1"

if [[ -z "$pkg" ]]; then
    echo "Usage: install_pkg <package_name>"
    exit 1
fi

if command -v apt >/dev/null 2>&1; then
    #echo "==> Installing $pkg (Ubuntu/Debian)..."
    sudo apt install -y "$pkg"

elif command -v pacman >/dev/null 2>&1; then
    #echo "==> Installing $pkg (Arch)..."
    sudo pacman -Sy --noconfirm "$pkg"

elif command -v dnf >/dev/null 2>&1; then
    #echo "==> Installing $pkg (Fedora/Red Hat)..."
    sudo dnf install -y "$pkg"

elif command -v yum >/dev/null 2>&1; then
    #echo "==> Installing $pkg (RHEL/CentOS with yum)..."
    sudo yum install -y "$pkg"

else
    echo "No supported package manager found (apt, pacman, dnf, yum)."
    exit 1
fi

