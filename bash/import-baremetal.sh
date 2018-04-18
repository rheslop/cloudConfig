#!/bin/bash

BAREMETAL_FILE=$1
SYSTEM=$(cat $BAREMETAL_FILE | awk '/- name:/ {print $3}' | head -n1)
source /home/stack/overcloudrc
DEPLOY_KERNEL=`openstack image show deploy-kernel -f value -c id`
DEPLOY_RAMDISK=`openstack image show deploy-ramdisk -f value -c id`

openstack baremetal create $BAREMETAL_FILE

openstack baremetal node set $SYSTEM --driver-info deploy_kernel=$DEPLOY_KERNEL --driver-info deploy_ramdisk=$DEPLOY_RAMDISK

openstack baremetal node set $SYSTEM --property capabilities=boot_option:local,boot_mode:uefi

ironic node-set-provision-state $SYSTEM manage
ironic node-set-provision-state $SYSTEM provide
