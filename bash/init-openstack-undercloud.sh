#!/bin/bash

# echo "Do not run until hostname and interfaces are configured."
# exit 1

TEMPLATE=/var/lib/libvirt/images/templates/rhel-server-7.8-x86_64-kvm.qcow2
# TEMPLATE=/var/lib/libvirt/images/templates/rhel-8.0-update-1-x86_64-kvm.qcow2
# TEMPLATE=/var/lib/libvirt/images/templates/rhel-8.1-x86_64-kvm.qcow2

CLOUDCONFIG=/home/rheslop/repositories/git/rheslop/cloudConfig
NAME=undercloud
DISK=/var/lib/libvirt/images/${NAME}.qcow2
HOST_NAME=director.controlstation.local

if [ ! -f $TEMPLATE ]; then
echo "$TEMPLATE NOT FOUND." ; echo "exiting." ; exit 1
fi

# eth0 configuration
cat > /tmp/ifcfg-eth0 << EOF
DEVICE="eth0"
BOOTPROTO="none"
ONBOOT="yes"
TYPE="Ethernet"
IPADDR="10.94.101.101"
NETMASK="255.255.255.0"
EOF

# eth1 configuration
cat > /tmp/ifcfg-eth1 << EOF
DEVICE="eth1"
BOOTPROTO="none"
ONBOOT="yes"
TYPE="Ethernet"
IPADDR="10.94.81.220"
NETMASK="255.255.255.0"
GATEWAY="10.94.81.1"
DNS1="8.8.8.8"
DNS2="1.1.1.1"
EOF

qemu-img create -f qcow2 ${DISK} 100G
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
--memory=16384 \
--vcpus=4 \
--disk path=$DISK \
--import \
--network network=Provisioning \
--network network=ootpa-2 \
--os-type=linux \
--os-variant=rhel7 \
--nographics \
--dry-run  \
--print-xml > /tmp/${NAME}.xml

qemu-img snapshot -c VANILLA ${DISK}

virsh define --file /tmp/${NAME}.xml && rm /tmp/${NAME}.xml
virsh start ${NAME}

echo -n "Waiting for ${NAME} to become available."
for i in {1..30}; do
  sleep .5 && echo -n "."
done
echo ""

cd ${CLOUDCONFIG}/ansible
if [ -f /root/.ssh/known_hosts ]; then ssh-keygen -R undercloud -f ~/.ssh/known_hosts; fi
# ansible-playbook --ask-vault-pass ${CLOUDCONFIG}/ansible/launchUndercloud.yml
