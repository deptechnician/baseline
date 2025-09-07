
# -------------------------------------
# Wakes up the office nas
# -------------------------------------
function wakeoff() {
    if command -v dnf >/dev/null 2>&1; then
        sudo ether-wake -i enp0s13f0u4c2 18:60:24:27:1f:b4
    else
        wakeonlan 18:60:24:27:1f:b4
    fi

    echo "Issued wake command."
}

wakeoff "$@"


