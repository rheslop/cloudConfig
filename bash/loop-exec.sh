#!/bin/bash

if [ -z $1 ]; then
	echo ""
	echo "Usage: $0 {loop}"
	echo "   ----------------"
	echo "   Available loops:"
	echo "   ----------------"
	echo "   delete-nested-stacks"
	echo ""
	exit 0
fi

case $1 in
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
