# -------------------------------------
# Aliases (ubuntu)
# -------------------------------------
alias aliasup="dep_script_aliasup && source $HOME/.bashrc"
alias bkusb='dep_script_bkusb'
alias bkprofile="$HOME/Code/dep/backup/linux/bkprofile.sh"
alias bk='bkprofile'
alias codium='flatpak run com.vscodium.codium'
alias changehost='dep_script_changehost'
alias clip='xclip -selection clipboard'
alias depenv='source ~/.venv/dep/bin/activate'
alias dirsize='du -h .'
alias diskspace="du -Sh | sort -n -r"
alias extract='dep_script_extract'
alias fnano='nano "$(find . -type f | fzf-tmux -p --reverse)"'
alias folders='du -h --max-depth=1'
alias ftext='dep_script_ftext'
alias gpt="ollama run llama3"
alias hostchange='dep_script_hostchange'
alias installapp='dep_script_installapp'
alias netscan="nmap -sn"
alias nasup='dep_script_nasup'
alias nasget='dep_script_nasget'
alias newbash=". $HOME/.bashrc"
alias pcat='dep_script_pcat'
alias provision='dep_script_provision'
alias privip='ip a | grep inet | grep -v inet6 | grep -v 127.0.0.1'
alias pubip='curl ipinfo.io'
alias push="dep_script_push"
alias pull="dep_script_pull"
alias ref='dep_script_ref'
alias sshnas="dep_script_sshnas"
alias sshagent='eval "$(ssh-agent -s)" '
alias sshload="dep_script_sshload"
alias sshkey='xclip -sel clip < $HOME/.ssh/depgithub.pub && xclip -o -sel clip'
alias sshlockdown='sudo cp $HOME/Code/dep/provision/linux/templates/sshd_config_soft /etc/ssh/sshd_config && sudo systemctl restart ssh'
alias syncup='dep_script_syncup'
alias syncdown='dep_script_syncdown'
alias test='dep_script_test'
alias tree='tree -CAhF --dirsfirst'
alias treed='tree -CAFd'
alias transcribe="whisper --model small"
alias transcripts='dep_script_transcripts'
alias update='dep_script_update'
alias vmsdown='dep_script_vmsdown'
alias wake='dep_script_wake'

# -------------------------------------
# Function to run a DEP script
# -------------------------------------
function dep_run_script() {
   Script="$1"
   shift
   "$HOME"/Code/baseline/scripts/"$Script" "$@"
}

# -------------------------------------
# List of dep scripts
# -------------------------------------
scripts=(
    "aliasup.sh" 
    "bkusb.sh" 
    "extract.sh" 
    "ftext.sh" 
    "hostchange.sh" 
    "installapp.sh"
    "nasget.sh" 
    "nasup.sh" 
    "pcat.sh" 
    "provision.sh"
    "pull.sh"
    "push.sh"
    "ref.sh"
    "sshload.sh"
    "sshnas.sh"
    "syncdown.sh"
    "syncup.sh"
    "update.sh"
    "vmsdown.sh"
    "wake.sh"
    "test.sh"
    "transcripts.sh")

# ----------------------------------------
# Function to dynamically create the 
#  functions used to invoke the scripts
#  so that the functions can be invoked
#  from the aliases
# ---------------------------------------
for script in "${scripts[@]}"; do
    # Create a function dynamically
    eval "
    function dep_script_${script%%.sh}() {
        dep_run_script $script \"\$@\"
    }"
done
