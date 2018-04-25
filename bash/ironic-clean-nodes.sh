#!/bin/bash
# Enable quick cleaning of overcloud node hard drives

source ~/stackrc
CTLPLANE_UUID=$(openstack network list | awk '/ctlplane/ {print $2}')

sudo crudini --set /etc/ironic/ironic.conf conductor automated_clean true
sudo crudini --set /etc/ironic/ironic.conf deploy erase_devices_priority 0
sudo crudini --set /etc/ironic/ironic.conf deploy erase_devices_metadata_priority 10
sudo crudini --set /etc/ironic/ironic.conf neutron cleaning_network_uuid $CTLPLANE_UUID

systemctl list-units | awk '/ironic/ {print $1}' | xargs -I {} sudo systemctl restart {}
