CUSTOM_TEMPLATES=/home/stack/cloudConfig/heat/deployments/rhosp-14/templates-ovs-ml2
TEMPLATES_HOME=/usr/share/openstack-tripleo-heat-templates

time openstack overcloud deploy --templates \
-e ${CUSTOM_TEMPLATES}/overcloud-images-env.yaml \
-e ${CUSTOM_TEMPLATES}/hostname-map.yaml \
-e ${TEMPLATES_HOME}/environments/network-isolation.yaml \
-e ${CUSTOM_TEMPLATES}/environments/network-environment.yaml \
-e ${CUSTOM_TEMPLATES}/environments/ip-layout.yaml \
-e ${CUSTOM_TEMPLATES}/sundry.yaml \
--ntp-server pool.ntp.org
