# -------------------------------------
# Function to update the aliases
# -------------------------------------
function aliasup() {
    if command -v dnf >/dev/null 2>&1; then
        mkdir -p ~/.bashrc.d
        cp "$HOME"/Code/baseline/bash_aliases "$HOME"/.bashrc.d
    else
        cp "$HOME"/Code/baseline/bash_aliases "$HOME"/.bash_aliases
    fi
}

aliasup "$@"
. "$HOME"/.bashrc.d/bash_aliases
echo "Aliases are updated"
