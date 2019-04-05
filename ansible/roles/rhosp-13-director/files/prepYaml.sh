SERVICES_DOCKER=/usr/share/openstack-tripleo-heat-templates/environments/services-docker
CUSTOM_TEMPLATES=/home/stack/cloudConfig/heat/deployments/rhosp-13/templates
DNS=8.8.8.8

source /home/stack/stackrc

openstack overcloud container image prepare \
--namespace registry.access.redhat.com/rhosp13 \
--output-images-file ${CUSTOM_TEMPLATES}/overcloud-images.yaml \
-e ${SERVICES_DOCKER}/neutron-ovn-dvr-ha.yaml

# Unused services
# -e ${SERVICES_DOCKER}/barbican.yaml \
# -e ${SERVICES_DOCKER}/octavia.yaml \
# -e ${SERVICES_DOCKER}/sensu-client.yaml \


sudo openstack overcloud container image upload \
--config-file ${CUSTOM_TEMPLATES}/overcloud-images.yaml


openstack overcloud container image prepare \
--namespace 192.168.101.101:8787/rhosp13 \
--output-env-file ${CUSTOM_TEMPLATES}/overcloud-images-env.yaml \
-e ${SERVICES_DOCKER}/neutron-ovn-dvr-ha.yaml

# Unused services
# -e ${SERVICES_DOCKER}/barbican.yaml \
-e ${SERVICES_DOCKER}/barbican.yaml \
-e ${SERVICES_DOCKER}/octavia.yaml \
-e ${SERVICES_DOCKER}/sensu-client.yaml \


SUBNET=$(openstack subnet list | awk '/ctlplane/ {print  $2}')
openstack subnet set --dns-nameserver $DNS $SUBNET
