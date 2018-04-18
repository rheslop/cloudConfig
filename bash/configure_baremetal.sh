source /home/stack/overcloudrc

echo "Variables not provided!"
exit 1

VLAN=
SUBNET=
GATEWAY=
DNSSERVER=
RANGE_START=
RANGE_END=

openstack network create --external --share \
--provider-network-type vlan \
--provider-physical-network datacentre \
--provider-segment $VLAN \
baremetal

openstack subnet create --network baremetal \
--subnet-range $SUBNET \
--gateway $GATEWAY \
--dns-namserver $DNSSERVER \
--allocation-pool start=${RANGE_START},end=${RANGE_END} \
baremetal-subnet

NET_UUID=$(openstack network list | awk '/baremetal/ {print $2}')

source /home/stack/stackrc

CONTROLLERS=$(nova list | awk '/controller/ {print $12}' | cut -d= -f2)

for i in $CONTROLLERS; do ssh heat-admin@${i} \
"sudo crudini --set /etc/ironic/ironic.conf neutron cleaning_network_uuid $NET_UUID" ; done

for i in $CONTROLLERS; do ssh heat-admin@${i} \
"sudo systemctl restart openstack-ironic-conductor" ; done

source /home/stack/overcloudrc

echo ""
echo "***********************************************************"
echo "* Baremetal configuration complete.                       *"
echo "*                                                         *"
echo "* Update /home/stack/templates/sundry.yaml with           *"
echo "*     ironic::conductor::cleaning_network_uuid: $NET_UUID *"
echo "***********************************************************"
echo ""

