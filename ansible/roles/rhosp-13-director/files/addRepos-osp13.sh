#!/bin/bash

subscription-manager repos --disable=*
subscription-manager repos \
--enable=rhel-7-server-rpms \
--enable=rhel-7-server-extras-rpms \
--enable=rhel-7-server-rh-common-rpms \
--enable=rhel-7-server-satellite-tools-6.2-rpms \
--enable=rhel-ha-for-rhel-7-server-rpms \
--enable=rhel-7-server-openstack-13-rpms \
--enable=rhel-7-server-rhceph-3-osd-rpms \
--enable=rhel-7-server-rhceph-3-mon-rpms \
--enable=rhel-7-server-rhceph-3-tools-rpms 
