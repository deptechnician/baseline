
# -------------------------------------
# Wakes up the lab host
# -------------------------------------
function wakelab() {
    if command -v dnf >/dev/null 2>&1; then
        sudo ether-wake bc:fc:e7:d5:45:08
    else
        wakeonlan bc:fc:e7:d5:45:08
    fi

    echo "Issued wake command."
}

wakelab "$@"


