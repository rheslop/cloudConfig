#!/bin/bash

/usr/bin/openstack tripleo container image prepare default \
--local-push-destination \
--output-env-file ~/containers-prepare-parameter.yaml
