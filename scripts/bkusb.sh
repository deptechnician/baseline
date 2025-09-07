# Backup to a usb
function bkusb() {
    if [ -z "$1" ]; then
        echo " "
        echo "Usage: bkusb <profile> <destination>"
        echo "  Example: bkusb documents /mnt/e/2411"
        echo " "
    else
        if [ -d "$2" ]; then
            bash "$HOME/Code/dep/backup/linux/bkprofile.sh" "$1" "$2"
        else
            echo "$2 does not exist"
        fi
    fi
}
 
bkusb "$@"
