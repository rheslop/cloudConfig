TEMPLATES_DIR=/home/stack/cloudConfig/heat/deployments/rhosp-10/templates

time openstack overcloud deploy --templates \
--control flavor control --compute-flavor compute \
--control-scale 3 --compute-scale 3 \
-e $TEMPLATES_DIR/overcloud_images.yaml \
-e $TEMPLATES_DIR/hostname-map.yaml \
-e $TEMPLATES_DIR/firstboot.yaml \
--ntp-server pool.ntp.org
