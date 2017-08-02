# +------+
# | curl |
# +------+

curl -O http://download.cirros-cloud.net/0.3.5/cirros-0.3.5-x86_64-disk.img

# +------+
# | wget |
# +------+

# wget http://download.cirros-cloud.net/0.3.5/cirros-0.3.5-x86_64-disk.img

# +-------------------------------------+
# | Convert image if using Ceph storage |
# +-------------------------------------+

# qemu-img convert -f qcow2 -O raw cirros-0.3.5-x86_64-disk.img cirros-0.3.5-x86_64-disk.raw
# openstack image create --disk-format raw --container-format bare --file cirros-0.3.5-x86_64-disk.raw cirros

openstack image create --disk-format qcow2 --container-format bare --file cirros-0.3.5-x86_64-disk.img cirros
