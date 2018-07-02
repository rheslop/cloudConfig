TEMPLATES_DIR=/home/stack/cloudConfig/heat/deployments/rhosp-13/templates
DNS=8.8.8.8

source /home/stack/stackrc

openstack overcloud container image prepare \
--namespace registry.access.redhat.com/rhosp13 \
--output-images-file ${TEMPLATES_DIR}/overcloud-images.yaml \
-e /usr/share/openstack-tripleo-heat-templates/environments/services-docker/barbican.yaml \
-e /usr/share/openstack-tripleo-heat-templates/environments/services-docker/octavia.yaml \
-e /usr/share/openstack-tripleo-heat-templates/environments/services-docker/sensu-client.yaml

sudo openstack overcloud container image upload \
--config-file ${TEMPLATES_DIR}/overcloud-images.yaml

openstack overcloud container image prepare \
--namespace 192.168.101.101:8787/rhosp13 \
--output-env-file ${TEMPLATES_DIR}/overcloud-images-env.yaml

SUBNET=$(openstack subnet list | awk '/ctlplane/ {print  $2}')
openstack subnet set --dns-nameserver $DNS $SUBNET
