#!/bin/bash

source ./init-openstack-vars.sh

cat > /etc/sysconfig/network-scipts/ifcfg-${PHYSICAL_DEVICE} << EOF
TYPE=Ethernet
DEVICE=$PHYSICAL_DEVICE
BOOTPROTO=none
HWADDR=$(ip addr show $PHYSICAL_DEVICE | awk '/ether/ {print $2}')
ONBOOT=yes
BRIDGE=br0
NM_CONTROLLED=no
EOF

cat > /etc/sysconfig/network-scripts/ifcfg-br0 << EOF
TYPE=Bridge
DEVICE=br0
BOOTROTO=none
NAME=br0
ONBOOT=yes
DELAY=0
IPADDR=${IP_ADDRESS}
PREFIX=${MASK_BITS}
GATEWAY=${GATEWAY_OUT}
DNS1=${DNS_ONE}
DNS2=${DNS_TWO}
EOF

if [ -f /etc/redhat-release ]; then
OS=$(cat /etc/redhat-release | awk '{print $1}')
fi

if [ "$OS" == "Fedora" ]; then
echo "ZONE=${FIREWALLD_ZONE}" >> /etc/sysconfig/network-scipts/ifcfg-${PHYSICAL_DEVICE}
echo "ZONE=${FIREWALLD_ZONE}" >> /etc/sysconfig/network-scipts/ifcfg-br0
fi

