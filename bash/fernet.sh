#!/bin/basn

source /home/stack/stackrc
sudo keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
sleep 2
sudo tar -zcf /home/stack/keystone-fernet-keys.tar.gz /etc/keystone/fernet-keys
upload-swift-artifacts -f /home/stack/keystone-fernet-keys.tar.gz

cat > /home/stack/templates/fernet.yaml << EOF
parameter_defaults:
  controllerExtraConfig:
    keystone::token_provider: 'fernet'
EOF

echo "Fernet has been configured for the Overcloud."
echo "When deploying, include the ferent.yaml template:"
echo ""
echo "openstack overcloud deploy --templates -e fernet.yaml"
