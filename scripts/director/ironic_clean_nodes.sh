# enable quick cleaning of overcloud node hard drives

source ~/stackrc
ctlplane_net_id=$(openstack network list | grep -i ctlplane | awk '{print $2;}')
sudo crudini --set /etc/ironic/ironic.conf conductor automated_clean true
sudo crudini --set /etc/ironic/ironic.conf deploy erase_devices_priority 0
sudo crudini --set /etc/ironic/ironic.conf deploy erase_devices_metadata_priority 10
sudo crudini --set /etc/ironic/ironic.conf neutron cleaning_network_uuid $ctlplane_net_id
systemctl list-units | awk '/ironic/ {print $1}' | xargs -I {} sudo systemctl restart {}
