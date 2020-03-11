#!/bin/bash

function INTERROGATION {
read -p "subscription-manager username: " SUBMAN_USER
read -p -s "subscription-manager password: " SUMAN_PASS
read -p "subscription-manager pool: " SUBMAN_POOL
read -p -s "ContainerImageRegistryPass: " CONTAINER_IMAGE_REGISTRY_PASS
read -p "ContainerImageRegistryUser: " CONTAINER_IMAGE_REGISTRY_USER
}

function RUN_AS_STACK {
mkdir /home/stack/images
mkdir /home/stack/templates

openstack tripleo container image prepare default \
--local-push-destination \
--output-env-file containers-prepare-parameter.yaml

echo -e "ContainerImageRegistryCredentials:\n  registry.redhat.io:\n ${CONTAINER_IMAGE_REGISTRY_USER}:${CONTAINER_IMAGE_REGISTRY_PASS} | tee -a /home/stack/containers-prepare-parameter.yaml

for i in \
/usr/share/rhosp-director-images/overcloud-full-latest-16.0.tar \
/usr/share/rhosp-director-images/ironic-python-agent-latest-16.0.tar \
do tar -xvf ${i} --directory /home/stack/images ; done

cat <EOF >> undercloud.conf
[DEFAULT]
local_ip=192.168.101.101/24
EOF
}

function CONFIGURE_STACK {
useradd stack
echo "stack" | passwd --stdin stack
echo "stack ALL=(root) NOPASSWD:ALL" | tee -a /etc/suders.d/stack
chmod 0440 /etc/sudoers.d/stack
}

function CONFIGURE_HOST {
echo "192.168.101.101  director  director.servermain.local" | tee -a /etc/hosts 
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

sudo dnf install -y python3-tripleoclient rhosp-director-images
sudo dnf -y update
}

INTERROGATION
CONFIGURE_HOST
CONFIGURE_STACK

