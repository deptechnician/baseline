# -------------------------------------
# Aliases
# -------------------------------------
alias aliasup="cp $HOME/Code/baseline/bash_aliases $HOME/.bash_aliases && cp $HOME/Code/baseline/bash_sshinit $HOME/.bash_sshinit && source $HOME/.bashrc"
alias bkusb='bkusb_function'
alias bkprofile="$HOME/Code/dep/backup/linux/bkprofile.sh"
alias bk='bkprofile'
alias cpp='cpp_function'
alias changehost='changehost_function'
alias depenv='source ~/.venv/dep/bin/activate'
alias dirsize='du -h .'
alias diskspace="du -Sh | sort -n -r"
alias extract='extract_function'
alias folders='du -h --max-depth=1'
alias ftext='ftext_function'
alias getnas='getnas_function'
alias gpt="ollama run llama3"
alias mounte="sudo mount -t drvfs E: /mnt/e"
alias netscan="nmap -sn"
alias pcat=provision_cat_function
alias provision='provision_function'
alias privip='ip a | grep inet | grep -v inet6 | grep -v 127.0.0.1'
alias pubip='curl ipinfo.io'
alias ref='display_reference_file'
alias sshnas="sshnas_function"
alias sshagent='eval "$(ssh-agent -s)" '
alias sshinit="pushd . && cd ~/.ssh && sshagent && ssh-add officenas && ssh-add depgithub && popd"
alias sshkey='xclip -sel clip < $HOME/.ssh/depgithub.pub && xclip -o -sel clip'
alias sshlockdown='sudo cp $HOME/Code/dep/provision/linux/templates/sshd_config_soft /etc/ssh/sshd_config && sudo systemctl restart ssh'
alias syncup='syncup_function'
alias syncdown='syncdown_function'
alias tree='tree -CAhF --dirsfirst'
alias treed='tree -CAFd'
alias transcribe="whisper --model small"
alias update='sudo apt update && sudo apt upgrade -y'

# -------------------------------------
# Initialize ssh if needed
# -------------------------------------
#if [ -f "$HOME/.bash_sshinit" ]; then
#    . "$HOME/.bash_sshinit"
#fi

# Backup to a usb
function bkusb_function() {
    if [ -z "$1" ]; then
        echo " "
        echo "Usage: bkusb <profile> <destination>"
        echo "  Example: bkusb paul-linux /mnt/e/2411"
        echo " "
    else
        if [ -d "$2" ]; then
            bash "$HOME/Code/dep/backup/linux/bkprofile.sh" "$1" "$2"
        else
            echo "$2 does not exist"
        fi
    fi
}

# Pull down content from the nas to the current directory
function getnas_function() {
    NAS_FILE=$HOME/.dep/nas.conf
    if [ -f "$NAS_FILE" ]; then
        source "$NAS_FILE"
        echo ""
        echo "$NAS_ADDRESS"
        echo "$NAS_PATH"
        echo "Copying this command to the clipboard: ssh $NAS_USER@$NAS_ADDRESS"
        echo "ssh $NAS_USER@$NAS_ADDRESS" | xclip -selection clipboard
        echo ""
    else
        echo "Cannot find configuration file $NAS_FILE"
    fi
}

# Pull down content from the nas to the current directory
function sshnas_function() {
    NAS_FILE=$HOME/.dep/nas.conf
    if [ -f "$NAS_FILE" ]; then
        source "$NAS_FILE"
        echo ""
        echo "$NAS_ADDRESS"
        echo "$NAS_PATH"
        ssh $NAS_USER@$NAS_ADDRESS
    else
        echo "Cannot find configuration file $NAS_FILE"
    fi
}

# Pull down content from the nas to the current directory
function changehost_function() {
    # Ensure a new hostname is provided
    if [ -z "$1" ]; then
        echo "Usage: changehost <new-hostname>"
    else
        NEW_HOSTNAME="$1"

        # Set the new hostname using hostnamectl
        hostnamectl set-hostname "$NEW_HOSTNAME"

        # Update /etc/hosts entry for 127.0.1.1
        sudo sed -i "s/^\(127\.0\.1\.1\s\+\).*$/\1$NEW_HOSTNAME/" /etc/hosts

        # Confirm the change
        echo "Hostname changed to: $NEW_HOSTNAME"
        echo "You should reboot to fully apply changes."
    fi
}

# Syncup command - uploads the current folder to a destination folder such that the destination mirrors the current folder
function syncup_function() {
    if [ -z "$1" ]; then
        echo " "
        echo "Usage: syncup [destination]"
        echo " "
        echo "Uploads the content from the current folder and mirrors it into a destination folder"
        echo " "
        echo "Example: syncup paul@nas-homelab:$HOME/nas"
        echo " "
    else
        rsync -avzP --delete --no-group ./ "$1"
    fi
}

# Syncdown command - uploads the current folder to a destination folder such that the destination mirrors the current folder
function syncdown_function() {
    if [ -z "$1" ]; then
        echo " "
        echo "Usage: syncdown [source]"
        echo " "
        echo "Downloads the content from a source folder and mirrors it into the current folder"
        echo " "
        echo "Example: syncdown paul@nas-homelab:$HOME/nas"
        echo " "
    else
        rsync -avzP --delete --no-group "$1" ./
    fi
}

# Installs an individual module
function provision_function() {
    local filename="$HOME/Code/dep/provision/linux/install/$1.sh"

    if [ -z "$1" ]; then
        echo " "
        echo "Usage: provision [module]"
        echo " "
        echo "You can pick from the following modules"
        echo "--------------------------------------"
        find $HOME/Code/dep/provision/linux/install -maxdepth 1 -type f -exec basename {} \; | sed 's/\.[^.]*$//' | sort   
        echo " "
    else
        pushd .
        cd $HOME/Code/dep/provision/linux
        bash "install/$1.sh"
        popd
    fi
}

# Shows the provisioning script for an individual module
function provision_cat_function() {
    local filename="$HOME/Code/dep/provision/linux/install/$1.sh"

    if [ -z "$1" ]; then
        echo " "
        echo "Usage: pcat [module]"
        echo " "
        echo "You can pick from the following modules"
        echo "--------------------------------------"
        find $HOME/Code/dep/provision/linux/install -maxdepth 1 -type f -exec basename {} \; | sed 's/\.[^.]*$//' | sort   
        echo " "
    else
        pushd .
        cd $HOME/Code/dep/provision/linux
        cat "install/$1.sh"
        popd
    fi
}

# Displays reference material, like cliff notes for man pages
function display_reference_file() {
    local filename="$HOME/Code/dep/provision/linux/reference/$1.sh"

    if [ -z "$1" ]; then
        echo " "
        echo "Usage: ref [topic]"
        echo " "
        echo "You can pick from the following topics"
        echo "--------------------------------------"
        find $HOME/Code/dep/provision/linux/reference -maxdepth 1 -type f -exec basename {} \; | sed 's/\.[^.]*$//'
        echo " "
    else
        cat $filename
    fi
}

# Extracts any archive(s) (if unp isn't installed)
extract_function() {
        for archive in "$@"; do
                if [ -f "$archive" ]; then
                        case $archive in
                        *.tar.bz2) tar xvjf $archive ;;
                        *.tar.gz) tar xvzf $archive ;;
                        *.bz2) bunzip2 $archive ;;
                        *.rar) rar x $archive ;;
                        *.gz) gunzip $archive ;;
                        *.tar) tar xvf $archive ;;
                        *.tbz2) tar xvjf $archive ;;
                        *.tgz) tar xvzf $archive ;;
                        *.zip) unzip $archive ;;
                        *.Z) uncompress $archive ;;
                        *.7z) 7z x $archive ;;
                        *) echo "don't know how to extract '$archive'..." ;;
                        esac
                else
                        echo "'$archive' is not a valid file!"
                fi
        done
}

# Searches for text in all files in the current folder
ftext_function() {
        # -i case-insensitive
        # -I ignore binary files
        # -H causes filename to be printed
        # -r recursive search
        # -n causes line number to be printed
        # optional: -F treat search term as a literal, not a regular expression
        # optional: -l only print filenames and not the matching lines ex. grep -irl "$1" *
        grep -iIHrn --color=always "$1" . | less -r
}

# Copy file with a progress bar
cpp_function() {
        set -e
        strace -q -ewrite cp -- "${1}" "${2}" 2>&1 |
                awk '{
        count += $NF
        if (count % 10 == 0) {
                percent = count / total_size * 100
                printf "%3d%% [", percent
                for (i=0;i<=percent;i++)
                        printf "="
                        printf ">"
                        for (i=percent;i<100;i++)
                                printf " "
                                printf "]\r"
                        }
                }
        END { print "" }' total_size="$(stat -c '%s' "${1}")" count=0
}

