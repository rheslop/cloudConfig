#!/bin/bash

if [ -z $1 ]; then
	echo ""
	echo "Usage: $0 {loop}"
	echo ""
	echo "   ----------------"
	echo "   Available loops:"
	echo "   ----------------"
	echo "   all-available"
	echo "   delete-ironic-nodes"
	echo "   delete-nested-stacks"
	echo ""
	exit 0
fi

case $1 in
	all-available)
	for i in $(openstack baremetal node list -c UUID -f value); do
		openstack baremetal node provide ${i}
	done
	;;
	delete-ironic-nodes)
	for i in $(openstack baremetal node list -c UUID -f value); do
		openstack baremetal node delete ${i}
	done
	;;
	delete-nested-stacks)
	STACK_NAME=$(openstack stack list -c "Stack Name" -f value)
	for i in $(openstack stack list --nested | awk '/'$STACK_NAME'/ {print $2}'); do
		openstack stack delete ${i} --yes
	done
	;;
	*)
	echo "No such loop \"$1\""
	;;
esac	
