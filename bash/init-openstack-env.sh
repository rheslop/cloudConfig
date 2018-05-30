#!/bin/bash

# Define virtual networks

cat > /tmp/net-br0.xml << EOF
<network>
  <name>net-br0</name>
  <forward mode='bridge'/>
  <bridge name='br0'/>
</network>
EOF

virsh net-define /tmp/net-br0.xml
virsh net-start net-br0
virsh net-autostart net-br0
rm -rf /tmp/net-br0.xml

cat > /tmp/Provisioning.xml << EOF
<network>
  <name>Provisioning</name>
  <domain name='Provisioning' />
  <ip address='192.168.101.1' netmask='255.255.255.0'>
  </ip>
</network>
EOF

virsh net-define /tmp/Provisioning.xml
virsh net-start Provisioning
virsh net-autostart Provisioning
rm -rf /tmp/Provisioning.xml


cat > /tmp/Tenant.xml << EOF
<network>
  <name>Tenant</name>
  <domain name='Tenant' />
  <ip address='192.168.102.1' netmask='255.255.255.0'>
  </ip>
</network>
EOF

virsh net-define /tmp/Tenant.xml
virsh net-start Tenant
virsh net-autostart Tenant
rm -rf /tmp/Tenant.xml

cat > /tmp/InternalApi.xml << EOF
<network>
  <name>InternalApi</name>
  <domain name='InternalApi' />
  <ip address='192.168.103.1' netmask='255.255.255.0'>
  </ip>
</network>
EOF

virsh net-define /tmp/InternalApi.xml
virsh net-start InternalApi
virsh net-autostart InternalApi
rm -rf /tmp/InternalApi.xml

cat > /tmp/Storage.xml << EOF
<network>
  <name>Storage</name>
  <domain name='Storage' />
  <ip address='192.168.104.1' netmask='255.255.255.0'>
  </ip>
</network>
EOF

virsh net-define /tmp/Storage.xml
virsh net-start Storage
virsh net-autostart Storage
rm -rf /tmp/Storage.xml

cat > /tmp/StorageCluster.xml << EOF
<network>
  <name>StorageCluster</name>
  <domain name='StorageCluster' />
  <ip address='192.168.105.1' netmask='255.255.255.0'>
  </ip>
</network>
EOF

virsh net-define /tmp/StorageCluster.xml
virsh net-start StorageCluster
virsh net-autostart StorageCluster
rm -rf /tmp/StorageCluster.xml

# Controller (7G memory, 2 vcpus, 80 GiB HDD)
#

for i in 1 2 3; do
qemu-img create -f qcow2 /var/lib/libvirt/images/controller-${i}.qcow2 80G

/usr/bin/virt-install \
--disk path=/var/lib/libvirt/images/controller-${i}.qcow2 \
--network network=Provisioning,mac=52:54:81:00:a0:0${i} \
--network network=Tenant,mac=52:54:82:00:a0:0${i} \
--network network=InternalApi,mac=52:54:83:00:a0:0${i} \
--network network=net-br0,mac=52:54:FF:00:a0:0${i} \
--network network=Storage,mac=52:54:84:00:a0:0${i} \
--network network=StorageCluster,mac=52:54:85:00:a0:0${i} \
--name controller-${i} \
--vcpus 2 \
--ram 8192 \
--noautoconsole \
--os-type=linux \
--os-variant=rhel7 \
--dry-run --print-xml > /root/files/vms/controller-${i}.xml
virsh define --file /root/files/vms/controller-${i}.xml

done

# Compute (7G memory, 2 vcpus, 120 GiB HDD)
#

for i in 1 2 3; do
qemu-img create -f qcow2 /var/lib/libvirt/images/compute-${i}.qcow2 120G

/usr/bin/virt-install \
--disk path=/var/lib/libvirt/images/compute-${i}.qcow2 \
--network network=Provisioning,mac=52:54:81:01:a0:0${i} \
--network network=Tenant,mac=52:54:82:01:a0:0${i} \
--network network=InternalApi,mac=52:54:83:01:a0:0${i} \
--network network=Storage,mac=52:54:84:01:a0:0${i} \
--network network=StorageCluster,mac=52:54:85:01:a0:0${i} \
--name compute-${i} \
--cpu host,+svm \
--vcpus 2 \
--ram 8192 \
--noautoconsole \
--os-type=linux \
--os-variant=rhel7 \
--dry-run --print-xml > /root/files/vms/compute-${i}.xml
virsh define --file /root/files/vms/compute-${i}.xml

done

# Create virtual BMCs

sudo yum install https://www.rdoproject.org/repos/rdo-release.rpm
sudo yum install -y python-virtualbmc

vbmc add compute-1 --port 6231 --username admin --password password
vbmc add compute-2 --port 6232 --username admin --password password
vbmc add compute-3 --port 6233 --username admin --password password
vbmc add controller-1 --port 6211 --username admin --password password
vbmc add controller-2 --port 6212 --username admin --password password
vbmc add controller-3 --port 6213 --username admin --password password


for i in {1..3}; do vbmc start controller-${i}; vbmc start compute-${i}; done

cat << EOF > ~/openstack-ipmi.xml
<?xml version"1.0" encoding="utf-8"?>
<service>
  <short>IPMI control</short>
  <description>IPMI ports for openstack domains.</description>
  <port protocol="udp" port="6231"/> <!-- compute-1 -->
  <port protocol="udp" port="6232"/> <!-- compute-2 -->
  <port protocol="udp" port="6233"/> <!-- compute-3 -->
  <port protocol="udp" port="6211"/> <!-- controller-1 -->
  <port protocol="udp" port="6212"/> <!-- controller-2 -->
  <port protocol="udp" port="6213"/> <!-- controller-3 -->
</service>
EOF

firewall-offline-cmd --new-service-from-file=/root/openstack-ipmi.xml --name=openstack-ipmi

cp /etc/firewalld/services/openstack-ipmi.xml /usr/lib/firewalld/services/

systemctl restart firewalld.service

firewall-cmd --add-service openstack-ipmi
firewall-cmd --add-service openstack-ipmi --permanent

