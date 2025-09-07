for vmid in $(qm list | awk '{if(NR>1)print $1}'); do qm shutdown $vmid; done 
#/sbin/shutdown -h now
