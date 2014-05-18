#!/bin/bash
#  Update all guests with these scripts
baseIP="192.168.122."
passWD="XenGuest"
targetPath="/usr/local/xen/scripts"

# for IP in 87 143 204; 
for IP in 118; 
do
	fullIP=${baseIP}${IP}
	echo "Updating IP ${fullIP}"
	scp * root@${fullIP}:$targetPath
done

