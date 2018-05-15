TEMPLATES_DIR=/home/stack/cloudConfig/heat/deployments/rhosp-11/templates

time openstack overcloud deploy --templates \
--control-scale 3 --compute-scale 3 \
-e $TEMPLATES_DIR/hostname-map.yaml \
--control-flavor baremetal \
--compute-flavor baremetal \
--ntp-server pool.ntp.org
