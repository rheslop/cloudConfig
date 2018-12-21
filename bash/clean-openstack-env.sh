#!/bin/bash

for i in {1..3}; do

  if virsh list --all | grep controller-${i}; then
    if virsh list | grep controller-${i}; then
      virsh destroy controller-${i}
    else
      echo "controller-${i} not running."
    fi
    virsh undefine controller-${i}
    rm /var/lib/libvirt/images/controller-${i}.qcow2
  else
    echo "controller-${i} not found."
  fi

done

for i in 1 2; do

  if virsh list --all | grep compute-${i}; then
    if virsh list | grep compute-${i}; then
      virsh destroy compute-${i}
    else
      echo "compute-${i} not running."
    fi
    virsh undefine compute-${i}
    rm /var/lib/libvirt/images/compute-${i}.qcow2
  else
    echo "compute-${i} not found."
  fi

done

if virsh list --all | grep undercloud; then
  if virsh list | grep undercloud; then
    virsh destroy undercloud
  else
    echo "undercloud not running"
  fi
  virsh undefine undercloud
  rm /var/lib/libvirt/images/undercloud.qcow2
else
  echo "undercloud not found."
fi

