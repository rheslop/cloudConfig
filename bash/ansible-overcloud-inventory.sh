#!/bin/bash
#
#------------------------------
# Get controller's IP addresses
#------------------------------
CONTROLLERS=$(nova list | awk '/controller/ {print $12}' | cut -d= -f2)

#------------------------------
# Get compute's IP addresses
#------------------------------
COMPUTES=$(nova list | awk '/compute/ {print $12}' | cut -d= -f2)

cat > $HOSTS_FILE << EOF
[controllers]
$CONTROLLERS

[computes]
$COMPUTES

[osp:children]
controllers
computes

EOF
