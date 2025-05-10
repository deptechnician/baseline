echo "------------------------------------------------------------------------"
echo " Utilities"
echo "------------------------------------------------------------------------"

if [[ -f ~/.utilities ]]; then
    echo "utilities are already configured"
else
    bash install/helper-apt.sh avahi-utils avahi-utils avahi-utils
    bash install/helper-apt.sh nmap
    bash install/helper-apt.sh make make make
    bash install/helper-apt.sh lm-sensors lm-sensors lm-sensors
    bash install/helper-apt.sh xclip xclip xclip
    bash install/helper-apt.sh yq yq yq
    bash install/helper-apt.sh nano nano nano
    bash install/helper-apt.sh curl curl "curl"
    bash install/helper-apt.sh wget wget "wget"
    bash install/helper-apt.sh multitail multitail "multitail"
    bash install/helper-apt.sh tree tree "tree"
    bash install/helper-apt.sh fzf fzf "fzf"
    bash install/helper-apt.sh bash-completion bash-completion "bash-completion"
    bash install/helper-apt.sh tmux tmux tmux
    #bash install/helper-apt.sh zoxide zoxide "zoxide"
    #bash install/helper-apt.sh trash-cli trash-cli "trash-cli"
fi

echo "Completed utilities"
echo " "

