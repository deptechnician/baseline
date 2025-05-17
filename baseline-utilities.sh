echo "------------------------------------------------------------------------"
echo " Utilities"
echo "------------------------------------------------------------------------"

if [[ -f ~/.utilities ]]; then
    echo "utilities are already configured"
else
    bash helper-apt.sh git git git
    bash helper-apt.sh avahi-utils avahi-utils avahi-utils
    bash helper-apt.sh nmap
    bash helper-apt.sh make make make
    bash helper-apt.sh lm-sensors lm-sensors lm-sensors
    bash helper-apt.sh xclip xclip xclip
    bash helper-apt.sh nano nano nano
    bash helper-apt.sh curl curl "curl"
    bash helper-apt.sh wget wget "wget"
    bash helper-apt.sh tree tree "tree"
    bash helper-apt.sh tmux tmux tmux
    bash helper-apt.sh keychain keychain keychain
    #bash helper-apt.sh zoxide zoxide "zoxide"
    #bash helper-apt.sh trash-cli trash-cli "trash-cli"
fi

echo "Completed utilities"
echo " "

