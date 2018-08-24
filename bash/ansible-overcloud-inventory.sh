#!/bin/bash
#
HOSTS_FILE=
#
if [ -z $HOSTS_FILE ]; then
	echo '$HOSTS_FILE is empty.'
	exit 1
fi
#
#------------------------------
# Get controller's IP addresses
#------------------------------
CONTROLLERS=$(openstack server list | awk '/controller/ {print $8}' | cut -c 10-)

#------------------------------
# Get compute's IP addresses
#------------------------------
COMPUTES=$(openstack server list  | awk '/compute/ {print $8}' | cut -c 10-)

cat > $HOSTS_FILE << EOF
[controllers]
$CONTROLLERS

[computes]
$COMPUTES

[osp:children]
controllers
computes

EOF
