TEMPLATES_DIR=/home/stack/cloudConfig/heat/deployments/rhosp-10/templates

time openstack overcloud deploy --templates \
--control-scale 3 --compute-scale 3 \
-e $TEMPLATES_DIR/hostname-map.yaml \
-e $TEMPLATES_DIR/environments/network-environment.yaml \
-e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
-e $TEMPLATES_DIR/environments/ip-layout.yaml \
-e $TEMPLATES_DIR/sundry.yaml \
--control-flavor baremetal \
--compute-flavor baremetal \
--ntp-server pool.ntp.org
