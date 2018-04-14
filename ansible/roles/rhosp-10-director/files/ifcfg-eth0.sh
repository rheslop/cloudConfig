cat > /etc/sysconfig/network-scripts/ifcfg-eth0 << EOF
DEVICE="eth0"
NAME="eth0"
HWADDR="$(ip addr show eth0 | awk '/ether/ {print $2}')"
IPADDR="192.168.101.101"
NETMASK="255.255.255.0"
EOF

ifup eth0
