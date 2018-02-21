#!/bin/bash

subscription-manager repos --disable=*
subscription-manager repos \
--enable=rhel-7-server-rpms \
--enable=rhel-7-server-extras-rpms \
--enable=rhel-7-server-rh-common-rpms \
--enable=rhel-ha-for-rhel-7-server-rpms \
--enable=rhel-7-server-openstack-11-rpms \
--enable=rhel-7-server-openstack-11-tools-rpms \
--enable=rhel-7-server-openstack-11-optools-rpms 
