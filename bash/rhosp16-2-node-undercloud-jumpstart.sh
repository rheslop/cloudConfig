#!/bin/bash

function INTERROGATION {
read -p "subscription-manager username: " SUBMAN_USER
read -s -p "subscription-manager password: " SUMAN_PASS
read -p "subscription-manager pool: " SUBMAN_POOL

}

export function RUN_AS_STACK {

if [ -z ${SUBMAN_USER} ]; then
	read -p "subscription-manager username: " SUBMAN_USER
fi

if [ -z ${SUBMAN_PASS} ]; then
	read -s -p "subscription-manager password: " SUMAN_PASS
fi

su stack -c \
"mkdir /home/stack/images; mkdir /home/stack/templates"

openstack tripleo container image prepare default \
--local-push-destination \
--output-env-file /home/stack/containers-prepare-parameter.yaml

echo -e "  ContainerImageRegistryCredentials:\n    registry.redhat.io:\n      ${SUBMAN_USER}:${SUBMAN_PASS}\n" | tee -a /home/stack/containers-prepare-parameter.yaml

for i in \
/usr/share/rhosp-director-images/overcloud-full-latest-16.0.tar \
/usr/share/rhosp-director-images/ironic-python-agent-latest-16.0.tar
do tar -xvf ${i} --directory /home/stack/images; done

cat <EOF >> undercloud.conf
[DEFAULT]
local_ip=192.168.101.101/24
undercloud_public_host = 192.168.101.102
undercloud_admin_host = 192.168.101.103
local_interface = eth0
container_cli = podman
container_healthcheck_disabled = false
container_images_file = /home/stack/containers-prepare-parameter.yaml
enable_telemetry = false

[ctlplane-subnet]
inspection_iprange = 192.168.101.21,192.168.101.30
cidr = 192.168.101.0/24
gateway = 192.168.101.101
dhcp_start = 192.168.101.10
dhcp_end = 192.168.101.20
masquerade = true
EOF

# openstack undercloud install


}

function CONFIGURE_STACK {
useradd stack
echo 'stack' | passwd --stdin stack
echo 'stack ALL=(root) NOPASSWD:ALL' | tee -a /etc/sudoers.d/stack
chmod 0440 /etc/sudoers.d/stack
}

function CONFIGURE_HOST {
echo '192.168.101.101  director  director.servermain.local' | tee -a /etc/hosts 
subscription-manager register --username=${SUBMAN_USER} --password=${SUBMAN_PASS}
subscription-manager attach --pool=${SUBMAN_POOL}
subscription-manager repos --disable=*
subscription-manager repos \
--enable=rhel-8-for-x86_64-baseos-rpms \
--enable=rhel-8-for-x86_64-appstream-rpms \
--enable=rhel-8-for-x86_64-highavailability-rpms \
--enable=ansible-2.8-for-rhel-8-x86_64-rpms \
--enable=openstack-16-for-rhel-8-x86_64-rpms \
--enable=fast-datapath-for-rhel-8-x86_64-rpms

dnf install -y python3-tripleoclient rhosp-director-images
dnf -y update
}

# INTERROGATION
# CONFIGURE_STACK
# CONFIGURE_HOST

su stack -c "bash -c RUN_AS_STACK"
