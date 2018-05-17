TEMPLATES_DIR=/home/stack/cloudConfig/heat/deployments/rhosp-12/templates

time openstack overcloud deploy --templates \
--control-flavor baremetal --compute-flavor baremetal \
--control-scale 3 --compute-scale 3 \
-e $TEMPLATES_DIR/overcloud_images.yaml \
-e $TEMPLATES_DIR/hostname-map.yaml \
-e $TEMPLATES_DIR/post-config.yaml \
--ntp-server pool.ntp.org
