#!/bin/bash

echo "Do not run until hostname and interfaces are configured."
exit 1


TEMPLATE=/var/lib/libvirt/images/rhel-server-7.4-x86_64-kvm.qcow2
NAME=director-${RANDOM}
DISK=/var/lib/libvirt/images/${NAME}.qcow2
HOST_NAME=

if [ ! -f $TEMPLATE ]; then
echo "$TEMPLATE NOT FOUND."
echo "exiting."
exit 1
fi

# eth0 configuration
cat > /tmp/ifcfg-eth0 << EOF
DEVICE=eth0
ONBOOT=yes
TYPE=Ethernet
NM_CONTROLLED=no
BOOTPROTO=none
IPADDR=
NETMASK=
GATEWAY=
DNS1=
DNS2=
EOF

# eth1 configuration
cat > /tmp/ifcfg-eth1 << EOF
DEVICE=eth1
ONBOOT=yes
TYPE=Ethernet
NM_CONTROLLED=no
BOOTPROTO=none
IPADDR=
NETMASK=
EOF


qemu-img create -f qcow2 ${DISK} 60G
export LIBGUESTFS_BACKEND=direct

virt-resize --expand /dev/sda1 ${TEMPLATE} ${DISK}

virt-customize -a $DISK \
--root-password password:redhat \
--hostname ${HOST_NAME} \
--edit /etc/ssh/sshd_config:s/PasswordAuthentication\ no/PasswordAuthentication\ yes/g \
--edit /etc/ssh/sshd_config:s/#UseDNS\ yes/UseDNS\ no/g \
--ssh-inject root \
--run-command '/bin/yum -y remove cloud-init' \
--upload /tmp/ifcfg-eth0:/etc/sysconfig/network-scripts/ifcfg-eth0 \
--upload /tmp/ifcfg-eth1:/etc/sysconfig/network-scripts/ifcfg-eth1 \
--selinux-relabel

/usr/bin/virt-install --name ${NAME} \
--memory=65536 \
--vcpus=8 \
--disk path=$DISK \
--import \
--network bridge=br-external \
--network bridge=br-provision \
--nographics --hvm --os-variant=rhel7 \
--dry-run --print-xml > /tmp/${NAME}.xml

virsh define --file /tmp/${NAME}.xml && rm /tmp/${NAME}.xml
virsh start ${NAME}
