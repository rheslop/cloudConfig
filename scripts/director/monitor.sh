#!/bin/bash

if [ -z $1 ]; then
        echo "Usage:"
        echo "'monitor.sh create' or 'monitor.sh delete'"
        exit
fi

case $1 in
        create)
        watch -n 3 'nova list; openstack stack list --nested | grep FAIL; openstack stack resource list overcloud | grep -v CREATE_COMPLETE;'
        ;;
        delete)
        watch -n 3 'nova list; openstack stack resource list overcloud | grep -v DELETE_COMPLETE'
        ;;
esac
