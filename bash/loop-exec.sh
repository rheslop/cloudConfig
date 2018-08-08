#!/bin/bash

if [ -z $1 ]; then
	echo ""
	echo "Usage: $0 {loop}"
	echo ""
	echo "   ----------------"
	echo "   Available loops:"
	echo "   ----------------"
	echo "   all-available"
	echo "   all-manageable"
	echo "   delete-ironic-nodes"
	echo "   delete-nested-stacks"
	echo "   dump-introspection"
	echo ""
	exit 0
fi

case $1 in
	all-available)
	for i in $(openstack baremetal node list -c UUID -f value); do
		openstack baremetal node provide ${i}
	done
	;;
	all-manageable)
	for i in $(openstack baremetal node list -c UUID -f value); do
		openstack baremetal node manage ${i}
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
	dump-introspection)
	if [ ! -d /home/stack/introspection-data ] ; then mkdir /home/stack/introspection-data; fi
	for i in $(openstack baremetal node list -c Name -f value); do
		openstack baremetal introspection data save --file /home/stack/introspection-data/${i}.txt ${i}
	done
	;;
	*)
	echo "No such loop \"$1\""
	;;
esac	
