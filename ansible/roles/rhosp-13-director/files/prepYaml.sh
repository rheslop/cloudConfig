TEMPLATES_DIR=/home/stack/cloudConfig/heat/deployments/rhosp-13/templates
DNS=8.8.8.8

source /home/stack/stackrc

openstack overcloud container image prepare \
--namespace registry.access.redhat.com/rhosp13-beta \
--output-env-file ${TEMPLATES_DIR}/overcloud_images.yaml

# Overcloud nodes will fail to download containers from registry
# if no access to outside

SUBNET=$(openstack subnet list | awk '/ctlplane/ {print  $2}')
openstack subnet set --dns-nameserver $DNS $SUBNET
