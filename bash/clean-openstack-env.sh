#!/bin/bash



for i in {1..3}; do

  if virsh list | grep controller-${i}; then
    virsh destroy controller-${i}
  fi

  virsh undefine controller-${i}
  rm /var/lib/libvirt/images/controller-${i}.qcow2
done

for i in 1 2; do

  if virsh list | grep compute-${i}; then
    virsh destroy compute-${i}
  fi

  virsh undefine compute-${i}
  rm /var/lib/libvirt/images/compute-${i}.qcow2
done


if virsh list | grep undercloud; then
  virsh destroy undercloud
fi

virsh undefine undercloud
rm /var/lib/libvirt/images/undercloud.qcow2

