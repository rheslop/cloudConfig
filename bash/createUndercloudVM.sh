#!/bin/bash

# echo "Do not run until hostname and interfaces are configured."
# exit 1

CLOUDCONFIG=/root/cloudConfig
TEMPLATE=/var/lib/libvirt/images/vanilla/rhel-server-7.4-x86_64-kvm.qcow2
NAME=undercloud
DISK=/var/lib/libvirt/images/${NAME}.qcow2
HOST_NAME=director.servermain.local

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
IPADDR="192.168.101.101"
NETMASK="255.255.255.0"
GATEWAY="192.168.101.254"
EOF

# eth1 configuration
cat > /tmp/ifcfg-eth1 << EOF
DEVICE="eth1"
BOOTPROTO="none"
ONBOOT="yes"
TYPE="Ethernet"
NM_CONTROLLED="no"
IPADDR="192.168.0.101"
NETMASK="255.255.255.0"
GATEWAY="192.168.0.1"
DNS1="68.94.156.9"
DNS2="68.94.157.9"
EOF

qemu-img create -f qcow2 ${DISK} 80G
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
--memory=8192 \
--vcpus=2 \
--disk path=$DISK \
--import \
--network network=Provisioning \
--network network=net-br0 \
--os-type=linux \
--os-variant=rhel7 \
--nographics \
--dry-run  \
--print-xml > /tmp/${NAME}.xml

virsh define --file /tmp/${NAME}.xml && rm /tmp/${NAME}.xml
virsh start ${NAME}

echo -n "Waiting for VM."
for i in {1..8}; do 
  echo -n "."
done

cd ${CLOUDCONFIG}/ansible
ansible-playbook --ask-vault-pass ${CLOUDCONFIG}/ansible/launchUndercloud.yml
