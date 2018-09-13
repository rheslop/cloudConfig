#!/bin/bash

TMPDIR=/home/heat-admin			# Outputs sosreport to this directory on _overcloud_ node
DESTDIR=/home/stack/sosreport		# Scps sosreprot to this directory on _undercloud_
CASEID=0001				# Case ID for sosreport	

mkdir -p ${DESTDIR}

for i in $(nova list | awk '/ACTIVE/ {print $12}' | awk -F\= '{print $2}'); do
	ssh -o StrictHostKeyChecking=no heat-admin@${i} \
	"mkdir $TMPDIR/OLD_LOGS; mv $TMPDIR/sosreport-* $TMPDIR/OLD_LOGS/;
	sudo sosreport --case-id $CASEID --name \$HOSTNAME --batch --tmp-dir $TMPDIR;
	sudo chown heat-admin:heat-admin /home/heat-admin/sosreport-*"
	scp -o StrictHostKeyChecking=no \
	heat-admin@${i}:/home/heat-admin/sosreport-* ${DESTDIR}
done
