#!/bin/bash

if [ -z $1 ]; then
        echo "Usage:"
        echo "'monitor.sh create' or 'monitor.sh delete'"
        exit
fi

case $1 in
        create)
        watch -n 3 'nova list; heat stack-list --show-nested | grep FAILED; heat resource-list overcloud | grep -v CREATE_COMPLETE'
        ;;
        delete)
        watch -n 3 'nova list; heat resource-list overcloud | grep -v DELETE_COMPLETE'
        ;;
esac
