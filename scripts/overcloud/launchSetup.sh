source /home/stack/overcloudrc

/bin/bash ./getCirros
/bin/bash ./createFlavors.sh

# Create Network and subnet
NETID=$(openstack network create int-net | awk '/\| id/ {print $4}')
openstack subnet create int-subnet --network int-net --subnet-range 192.168.254.0/24

# Create VM
nova boot --image cirros --flavor os.micro --nic net-id=$NETID test-instance0

# Create volume
