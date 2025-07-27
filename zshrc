# ----------------------
# --- SSH initialization
# ----------------------
SSH_KEY="$HOME/.ssh/depclientnas"
if ! ssh-add -l | grep -q "$SSH_KEY"; then
  ssh-add "$SSH_KEY" 2>/dev/null
fi

# ----------------------
# ---- Aliases
# ----------------------
#
alias folders="du -h -d 1"
alias ll="ls -la"
alias sendup="sendup_function"

# ----------------------
# ---- Functions
# ----------------------
sendup_function() {
  if [ -z "$1" ]; then
    echo "Usage: sendup <destination>"
    return 1
  fi
  rsync -av --progress ./ "$1"
}


