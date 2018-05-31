#!/bin/bash

for i in {1..3}; do
  virsh undefine controller-${i}
  rm /var/lib/libvirt/images/controller-${i}.qcow2
done

for i in 1 2; do
  virsh undefine compute-${i}
  rm /var/lib/libvirt/images/compute-${i}.qcow2
done

virsh undefine undercloud
rm /var/lib/libvirt/images/undercloud.qcow2

