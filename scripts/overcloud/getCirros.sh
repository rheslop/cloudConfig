# Valid formats are RAW or QCOW2
FORMAT=QCOW2

source /home/stack/overcloudrc

if [ ! -d /home/stack/images ]; then mkdir -p /home/stack/images; fi
cd /home/stack/images

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
