#!/bin/bash
CUSTOM_TEMPLATES=/home/stack/cloudConfig/heat/deployments/rhosp-13/templates-ovs-ml2

openstack tripleo container image prepare default \
--local-push-destination \
--output-env-file ~/containers-prepare-parameter.yaml

sudo openstack tripleo container image prepare \
-e ~/containers-prepare-parameter.yaml

