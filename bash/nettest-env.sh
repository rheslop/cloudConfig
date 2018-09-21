#!/bin/bash

if [ -z $1 ]; then
	echo "Usage: $0 [setup|teardown]"
	exit 1
fi


source /home/stack/stackrc
STACK_NAME=$(openstack stack list -c "Stack Name" -f value)
OVERCLOUDRC=${STACK_NAME}rc
source $OVERCLOUDRC
KEY=30415
NET=migration-network-${KEY}
SUBNET=migration-subnet-${KEY}
FLAVOR=small-${KEY}
SRV=test-server-${KEY}
KEYPAIR=stack-user-${KEY}
GATEWAY=gateway-out-${KEY}

case $1 in
	setup)
		if [ -z $IMAGE ]; then
			echo "You must define an image to run setup."
			echo "Example: export IMAGE=rhel-7"
			exit 1
		fi
		if [ -z $EXTNET ]; then
			echo "You must define an external network to run setup."
			echo "Example: export EXTNET=external"
			exit 1
		fi

		if openstack flavor list -c Name -f value | grep $FLAVOR ; then : ;
		else openstack flavor create --ram 512 --disk 25 --vcpus 1 --id auto $FLAVOR ; fi
		if openstack network list -c Name -f value | grep $NET ; then : ;
		else openstack network create $NET; fi
		if openstack subnet list -c Name -f value | grep $SUBNET ; then : ;
		else openstack subnet create $SUBNET --network $NET --subnet-range 192.168.177.0/24 ; fi
		if openstack router list -c Name -f value | grep ${GATEWAY} ; then : ;
		else openstack router create ${GATEWAY}
		openstack router set ${GATEWAY} --external-gateway ${EXTNET}
		openstack router add subnet ${GATEWAY} ${SUBNET} ; fi
		if openstack keypair list -c Name -f value | grep ${KEYPAIR} ; then : ;
		else openstack keypair create --public-key /home/stack/.ssh/id_rsa.pub ${KEYPAIR} ; fi
		if openstack server list -c Name -f value | grep ${SRV}-1 ; then : ;
		else openstack server create --network $NET --flavor $FLAVOR --image $IMAGE --key-name ${KEYPAIR} ${SRV}-1 ; fi
		if openstack server list -c Name -f value | grep ${SRV}-2 ; then : ;
		else openstack server create --network $NET --flavor $FLAVOR --image $IMAGE --key-name ${KEYPAIR} ${SRV}-2 ; fi
	;;
	teardown)

		if openstack server list -c Name -f value | grep ${SRV}-2; then
		openstack server delete ${SRV}-2 ; fi
		if openstack server list -c Name -f value | grep ${SRV}-1; then
		openstack server delete ${SRV}-1 ; fi
		if openstack keypair list -c Name -f value | grep ${KEYPAIR}; then
		openstack keypair delete ${KEYPAIR} ; fi
		if openstack router list -c Name -f value | grep ${GATEWAY} ; then
		openstack router remove subnet ${GATEWAY} ${SUBNET}
		openstack router delete ${GATEWAY} ; fi
		if openstack subnet list -c Name -f value | grep $SUBNET ; then
		openstack subnet delete $SUBNET ; fi
		if openstack network list -c Name -f value | grep $NET ; then
		openstack network delete $NET ; fi
		if openstack flavor list -c Name -f value | grep $FLAVOR ; then
		openstack flavor delete $FLAVOR ; fi
	;;
	*)
	echo "Usage: $0 [setup|teardown]"
	exit 1
	;;
esac

