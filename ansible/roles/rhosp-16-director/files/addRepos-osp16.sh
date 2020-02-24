#!/bin/bash

subscription-manager release --set=8.0

subscription-manager repos --disable=*
subscription-manager repos \
--enable=rhel-8-for-x86_64-baseos-rpms \
--enable=rhel-8-for-x86_64-appstream-rpms \
--enable=rhel-8-for-x86_64-highavailability-rpms \
--enable=ansible-2.8-for-rhel-8-x86_64-rpms \
--enable=openstack-16-for-rhel-8-x86_64-rpms \
--enable=rhel-8-for-x86_64-nfv-rpms \
--enable=advanced-virt-for-rhel-8-x86_64-rpms \
--enable=fast-datapath-for-rhel-8-x86_64-rpms
