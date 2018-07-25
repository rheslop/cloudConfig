# Valid formats are RAW or QCOW2
FORMAT=QCOW2
IMAGESDIR=~/images
BASEOS=$(cat /etc/redhat-release | awk '{print $1}') 
OVERCLOUDRC=$(ls /home/stack | egrep rc$ | grep -v stackrc)

case ${BASEOS} in
	Red)
	  source /home/stack/$OVERCLOUDRC
	  ;;
	CentOS)
	  source /root/keystonerc_admin
	  ;;
	*)
	  echo "Not a recognized operating system."
	  exit 1
	  ;;
esac

if [ ! -d ${IMAGESDIR} ]; then mkdir -p ${IMAGESDIR}; fi
cd ${IMAGESDIR}

if [ ! -f cirros-0.3.5-x86_64-disk.img ]; then
  curl -O http://download.cirros-cloud.net/0.3.5/cirros-0.3.5-x86_64-disk.img
fi

case $FORMAT in
  RAW)
    # +-------------------------------------+
    # | Convert image if using Ceph storage |
    # +-------------------------------------+
    if [ ! -f cirros-0.3.5-x86_64-disk.raw ]; then
      qemu-img convert -f qcow2 -O raw cirros-0.3.5-x86_64-disk.img cirros-0.3.5-x86_64-disk.raw
    fi
    openstack image create --disk-format raw --container-format bare --file cirros-0.3.5-x86_64-disk.raw cirros
  ;;
  QCOW2)
    openstack image create --disk-format qcow2 --container-format bare --file cirros-0.3.5-x86_64-disk.img cirros
  ;;
  *)
    echo "INVALID FORMAT."
    exit 1
  ;;
esac

openstack flavor create --ram 512 --disk 5 --vcpus 1 --id auto os.micro
openstack flavor create --ram 1024 --disk 10 --vcpus 1 --id auto os.tiny
openstack flavor create --ram 2048 --disk 20 --vcpus 2 --id auto os.small
openstack flavor create --ram 4096 --disk 40 --vcpus 2 --id auto os.medium
openstack flavor create --ram 8192 --disk 80 --vcpus 4 --id auto os.large

# Create Network and subnet
NETID=$(openstack network create internal_network | awk '/\| id/ {print $4}')

openstack subnet create internal_subnet \
--network internal_network \
--dns-nameserver 8.8.8.8 \
--subnet-range 192.168.254.0/24

# Create VM
nova boot --image cirros --flavor os.micro --nic net-id=$NETID test-instance0

