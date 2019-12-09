CUSTOM_TEMPLATES=/home/stack/cloudConfig/heat/deployments/rhosp-15/templates-ovn
TEMPLATES_HOME=/usr/share/openstack-tripleo-heat-templates

time openstack overcloud deploy --templates \
-p ${CUSTOM_TEMPLATES}/plan-environment.yaml \
-e /home/stack/containers-prepare-parameter.yaml \
-e ${CUSTOM_TEMPLATES}/hostname-map.yaml \
-e ${TEMPLATES_HOME}/environments/network-isolation.yaml \
-e ${CUSTOM_TEMPLATES}/environments/network-environment.yaml \
-e ${CUSTOM_TEMPLATES}/environments/ip-layout.yaml \
--ntp-server pool.ntp.org

# -e ${CUSTOM_TEMPLATES}/overcloud-images-env.yaml \
