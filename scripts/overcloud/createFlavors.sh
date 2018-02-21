openstack flavor create --ram 512 --disk 5 --vcpus 1 --id auto os.micro
openstack flavor create --ram 1024 --disk 10 --vcpus 1 --id auto os.tiny
openstack flavor create --ram 2048 --disk 20 --vcpus 2 --id auto os.small
openstack flavor create --ram 4096 --disk 40 --vcpus 2 --id auto os.medium
openstack flavor create --ram 8192 --disk 80 --vcpus 4 --id auto os.large

