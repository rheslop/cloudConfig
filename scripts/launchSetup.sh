# Get Cirros

if [ ! -f cirros-0.3.5-x86_64-disk.img ]; then
  curl -O http://download.cirros-cloud.net/0.3.5/cirros-0.3.5-x86_64-disk.img || exit 1
fi

openstack image create --disk-format qcow2 --container-format bare --file cirros-0.3.5-x86_64-disk.img cirros

## Create Flavors
openstack flavor create --ram 512 --disk 5 --vcpus 1 --id auto os.micro
openstack flavor create --ram 1024 --disk 10 --vcpus 1 --id auto os.tiny
openstack flavor create --ram 2048 --disk 20 --vcpus 2 --id auto os.small
openstack flavor create --ram 4096 --disk 40 --vcpus 2 --id auto os.medium
openstack flavor create --ram 8192 --disk 80 --vcpus 4 --id auto os.large

### Create Network

openstack network create test
openstack subnet create test --network test --subnet-range 192.168.0.0/24

#### Create VM
