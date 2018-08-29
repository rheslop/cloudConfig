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
        echo "   custom-command"
	echo "   delete-ironic-nodes"
	echo "   delete-nested-stacks"
	echo "   dump-introspection"
        echo "   maintenance [on|off]"
	echo ""
	exit 0
fi

case $1 in
	all-available)
	source /home/stack/stackrc
	for i in $(openstack baremetal node list -c UUID -f value); do
		openstack baremetal node provide ${i}
	done
	;;
	all-manageable)
	source /home/stack/stackrc
	for i in $(openstack baremetal node list -c UUID -f value); do
		openstack baremetal node manage ${i}
	done
	;;
	delete-ironic-nodes)
	source /home/stack/stackrc
	for i in $(openstack baremetal node list -c UUID -f value); do
		openstack baremetal node delete ${i}
	done
	;;
	custom-command)
	source /home/stack/stackrc
	read -p "~> " CUSTOM_COMMAND
	for i in $(openstack server list -c Networks -f value | cut -d= -f2); do
		ssh heat-admin@${i} "${CUSTOM_COMMAND}"
	done
	;;
	delete-nested-stacks)
	source /home/stack/stackrc
	STACK_NAME=$(openstack stack list -c "Stack Name" -f value)
	for i in $(openstack stack list --nested | awk '/'$STACK_NAME'/ {print $2}'); do
		openstack stack delete ${i} --yes
	done
	;;
	dump-introspection)
	source /home/stack/stackrc
	if [ ! -d /home/stack/introspection-data ] ; then mkdir /home/stack/introspection-data; fi
	for i in $(openstack baremetal node list -c Name -f value); do
		openstack baremetal introspection data save --file /home/stack/introspection-data/${i}.txt ${i}
	done
	;;
	maintenance)
	source /home/stack/stackrc
        if [ -z $2 ]; then
		echo ""
		echo "Usage: $0 maintenance [on|off]"
		echo ""
		exit 1
	fi
	case $2 in
		on)
		for i in $(openstack baremetal node list -c Name -f value); do
		openstack baremetal node maintenance set ${i}
		done
		;;
		off)
                for i in $(openstack baremetal node list -c Name -f value); do
		openstack baremetal node maintenance unset ${i}
                done
		;;
		*)
		echo ""
		echo "Invalid maintenance state: \"$2\""
		echo "Usage: $0 maintenance [on|off]"
		echo ""
		exit 2
		;;
	esac
	;;	
	*)
	echo "No such loop \"$1\""
	;;
esac	
