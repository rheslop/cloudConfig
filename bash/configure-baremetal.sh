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
--dns-nameserver $DNSSERVER \
--allocation-pool start=${RANGE_START},end=${RANGE_END} \
baremetal-subnet

NET_UUID=$(openstack network list | awk '/baremetal/ {print $2}')

source /home/stack/stackrc

CONTROLLERS=$(nova list | awk '/controller/ {print $12}' | cut -d= -f2)

echo "Setting the cleaning network."
for i in $CONTROLLERS; do ssh heat-admin@${i} \
"sudo crudini --set /etc/ironic/ironic.conf neutron cleaning_network_uuid $NET_UUID" ; done

echo "Restarting openstack-ironic-conductor."
for i in $CONTROLLERS; do ssh heat-admin@${i} \
"sudo systemctl restart openstack-ironic-conductor" ; done

source /home/stack/overcloudrc

if [ -f /home/stack/images/ironic-python-agent.kernel ]; then
	echo "Uploading IPA kernel image."
	openstack image create --public --container-format aki --disk-format aki --file /home/stack/images/ironic-python-agent.kernel deploy-kernel
else
	echo "/home/stack/images/ironic-python-agent.kernel not found - exiting."
	exit 1
fi

if [ -f /home/stack/images/ironic-python-agent.initramfs ]; then
	echo "Uploading IPA initramfs."
	openstack image create --public --container-format ari --disk-format ari --file /home/stack/images/ironic-python-agent.initramfs deploy-ramdisk
else
	echo "/home/stack/images/ironic-python-agent.initramfs not found - exiting."
	exit 1
fi

if [ -f /home/stack/images/overcloud-full.vmlinuz ]; then
	echo "Uploading overcloud-full.vmlinuz."
	KERNEL_ID=$(openstack image create --file /home/stack/images/overcloud-full.vmlinuz --public --container-format aki --disk-format aki -f value -c id overcloud-full.vmlinuz)
else
	echo "/home/stack/images/overcloud-full.vmlinuz not found - exiting."
	exit 1
fi

if [ -f /home/stack/images/overcloud-full.initrd ]; then
	echo "Uploading overcloud-full.initrd."
	RAMDISK_ID=$(openstack image create --file /home/stack/images/overcloud-full.initrd --public --container-format ari --disk-format ari -f value -c id overcloud-full.initrd)
else
	echo "/home/stack/images/overcloud-full.initrd not found - exiting."
	exit 1
fi

if [ -f /home/stack/images/overcloud-full.qcow2 ]; then
	echo "Uploading overcloud-full.qcow2."
	openstack image create --file /home/stack/images/overcloud-full.qcow2 --public --container-format bare --disk-format qcow2 --property kernel_id=$KERNEL_ID --property ramdisk_id=$RAMDISK_ID rhel7-baremetal
else
	echo "/home/stack/images/overcloud-full.qcow2 not found - exiting."
	exit 1
fi

echo "Creating baremetal and virtual flavors..."
echo ""

openstack flavor create --ram 1024 --disk 20 --vcpus 1 baremetal
openstack flavor set baremetal --property baremetal=true

openstack flavor create --ram 1024 --disk 20 --vcpus 1 virtual
openstack flavor set virtual --property baremetal=false

echo "Creating aggregates..."

openstack aggregate create --property baremetal=true baremetal-hosts
openstack aggregate create --property baremetal=false virtual-hosts

for i in $(openstack hypervisor list -f value -c "Hypervisor Hostname" | grep -i compute); do
	openstack aggregate add host virtual-hosts $i
done

CONTROLLERS=$(openstack compute service list | awk '/troll/ {print $6}' | sort | uniq)
for i in $CONTROLLERS ; do openstack aggregate add host baremetal-hosts $i ; done

echo "Creating key pair."

openstack keypair create --public-key /home/stack/.ssh/id_rsa.pub undercloud-key

echo ""
echo "***********************************************************"
echo "* Baremetal configuration complete.                       *"
echo "*                                                         *"
echo "* Update /home/stack/templates/sundry.yaml with           *"
echo "*     ironic::conductor::cleaning_network_uuid: $NET_UUID *"
echo "***********************************************************"
echo ""

