#!/bin/bash

if [ -z $1 ]; then
        echo "Usage:"
        echo "'monitor.sh [create|update|delete]'"
        exit
fi

case $1 in
        create)
        watch -n 3 'ironic node-list; nova list; openstack stack list ; openstack stack list --nested | grep -v CREATE_C'
        ;;
        delete)
        watch -n 3 'ironic node-list; nova list; openstack stack list --nested'
        ;;
        update)
        watch -n 3 'ironic node-list; nova list; openstack stack list ; openstack stack list --nested | grep -v CREATE_C | grep -v UPDATE_C'

esac
