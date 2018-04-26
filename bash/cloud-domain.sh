#!/bin/bash

if [ -z $1 ]; then
	echo "Usage: $0 'domain.com'"
	exit 1
fi

sudo crudini --set /etc/nova/nova.conf DEFAULT dhcp_domain $1
sudo crudini --set /etc/neutron/neutron.conf DEFAULT dns_domain $1

systemctl list-units | awk '/nova/ {print $1}' | sudo xargs -I {} systemctl restart {}
systemctl list-units | awk '/neutron/ {print $1}' | sudo xargs -I {} systemctl restart {}

echo "Complete."
echo ""
echo "Ensure the CloudDomain parameter is added to your templates."
echo "::Example::"
echo ""
echo "parameter_defaults:"
echo "  CloudDomain: $1"
