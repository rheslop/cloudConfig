TEMPLATES_DIR=/home/stack/cloudConfig/heat/deployments/rhosp-12/templates
DNS=1.1.1.1

TAG=\
$(sudo openstack overcloud container image tag discover \
--image registry.access.redhat.com/rhosp12/openstack-base:latest \
--tag-from-label version-release)

openstack overcloud container image prepare \
--namespace=registry.access.redhat.com/rhosp12 \
--prefix=openstack- \
--tag=$TAG \
--env-file=${TEMPLATES_DIR}/overcloud_images.yaml

# Overcloud nodes will fail to download containers from registry
# if no access to outside

SUBNET=$(openstack subnet list | awk '/ctlplane/ {print  $2}')
openstack subnet set --dns-nameserver $DNS $SUBNET
