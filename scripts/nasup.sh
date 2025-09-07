# Bring the dep nas online
function nasup() {
    KEYFILE="/root/zfs_dep_key"

    # Loop through all datasets
    printf "\n"
    printf "%-30s %-15s\n" "Dataset" "Status"
    printf "%-30s %-15s\n" "----------------------------" "--------------------"
    sudo zfs list -H -o name | while read -r dataset; do
        #echo "Attempting to load key for: $dataset"
        if sudo zfs load-key -L "file://$KEYFILE" "$dataset" 2>/dev/null; then
            printf "%-30s %-15s\n" "$dataset" "Unlocked"
        else
            printf "%-30s %-15s\n" "$dataset" "Skipped, already unlocked"
        fi
    done

    # Mount all datasets
    printf "\n"
    echo "Mounting all datasets..."
    sudo zfs mount -a
    printf "Datasets mounted\n\n"
}

nasup "$@"

