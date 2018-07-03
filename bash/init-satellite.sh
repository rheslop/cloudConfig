#!/bin/bash

if [[ EUID -ne 0 ]]; then
echo "Permission denied - run script as root."
exit 1
fi


TEMPLATE=/var/lib/libvirt/images/templates/rhel-server-7.5-update-1-x86_64-kvm.qcow2
NAME=satellite
DISK1=/var/lib/libvirt/images/${NAME}-1.qcow2
DISK2=/var/lib/libvirt/images/${NAME}-2.qcow2
HOST_NAME=satellite.workstation.local

if [ ! -f $TEMPLATE ]; then
echo "$TEMPLATE NOT FOUND." ; echo "exiting." ; exit 1
fi

# eth0 configuration
cat > /tmp/ifcfg-eth0 << EOF
DEVICE="eth0"
BOOTPROTO="none"
ONBOOT="yes"
TYPE="Ethernet"
NM_CONTROLLED="no"
IPADDR="192.168.122.4"
NETMASK="255.255.255.0"
GATEWAY="192.168.101.254"
DNS1="8.8.8.8"
DNS2="8.8.4.4"
EOF

qemu-img create -f qcow2 ${DISK1} 40G
qemu-img create -f qcow2 ${DISK2} 100G
export LIBGUESTFS_BACKEND=direct

virt-resize --expand /dev/sda1 ${TEMPLATE} ${DISK1}

virt-customize -a ${DISK1} \
--root-password password:redhat \
--hostname ${HOST_NAME} \
--edit /etc/ssh/sshd_config:s/PasswordAuthentication\ no/PasswordAuthentication\ yes/g \
--edit /etc/ssh/sshd_config:s/#UseDNS\ yes/UseDNS\ no/g \
--ssh-inject root \
--run-command '/bin/yum -y remove cloud-init' \
--upload /tmp/ifcfg-eth0:/etc/sysconfig/network-scripts/ifcfg-eth0 \
--selinux-relabel

/usr/bin/virt-install --name ${NAME} \
--memory=16384 \
--vcpus=2 \
--disk path=${DISK1} \
--disk path=${DISK2} \
--import \
--network network=default \
--os-type=linux \
--os-variant=rhel7 \
--nographics \
--dry-run  \
--print-xml > /tmp/${NAME}.xml

qemu-img snapshot -c VANILLA ${DISK}

virsh define --file /tmp/${NAME}.xml && rm /tmp/${NAME}.xml
virsh start ${NAME}
