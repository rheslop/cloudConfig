#!/bin/bash
#
source /home/stack/overcloudrc

ALLOCATION_POOL_START=
ALLOCATION_POOL_END=
ALLOCATION_POOL_GATEWAY=
SUBNET_RANGE=

# Example:

# ALLOCATION_POOL_START=192.168.0.121
# ALLOCATION_POOL_END=192.168.0.130
# ALLOCATION_POOL_GATEWAY=192.168.0.1
# SUBNET_RANGE=192.168.0.0/24

for i in "${ALLOCATION_POOL_START}" "${ALLOCATION_POOL_END}" "${ALLOCATION_POOL_GATEWAY}" "${SUBNET_RANGE}"; do
	if [ "$i" == "" ]; then
		echo ""
		echo "The following variables must be populated before running this script:"
		echo ""
		echo "======================="
		echo "ALLOCATION_POOL_START"
		echo "ALLOCATION_POOL_END"
		echo "ALLOCATION_POOL_GATEWAY"
		echo "SUBNET_RANGE"
		echo "======================="
		echo ""
		echo "Exiting."
		echo ""
		exit 1
	fi
done


if [ -z "$1" ]; then
	echo "Please identify the subnet for which a route will be created"
	echo "Example: $0 [SUBNET]"
	exit
fi

SUBNET=$1

echo "This script assumes that subnet $1"
echo "has a gateway ip set, which will be used"
echo "as the interface out. Is this accurate? [y|n]"
echo ""
read -p ' ~>' CONFIRM

function CONFIRMATION {

case $CONFIRM in
	y)
	:
	;;
	n)
	echo "aborting."
	exit
	;;
	*)
	echo "Please type 'y' or 'n'."
	echo ""
	CONFIRMATION
	;;
esac

}

GATEWAY_IP=$(openstack subnet show int-subnet | awk '/gateway_ip/ {print $4}')

# Create the external network

openstack network create extnet --share --external \
--provider-physical-network datacentre \
--provider-network-type flat

# Create the external subnet

openstack subnet create subnet-extnet --network extnet \
--allocation-pool start=${ALLOCATION_POOL_START},end=${ALLOCATION_POOL_END} \
--gateway ${ALLOCATION_POOL_GATEWAY} \
--dns-nameserver 8.8.8.8 \
--subnet-range ${SUBNET_RANGE}

openstack router create gateway_out
neutron router-gateway-set gateway_out extnet
openstack router add subnet gateway_out ${SUBNET}

# openstack floating ip create --subnet extnet --port [?] --floating-ip-address 192.168.0.121 extnet
# openstack floating ip create --subnet subnet-extnet --port ad43bfbc-c368-4ba2-a9d4-57b1deaa79a4 extnet
