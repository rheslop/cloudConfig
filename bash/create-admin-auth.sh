echo "export OSP_USERNAME=admin" >> /home/stack/admin_auth
echo "export OSP_PROJECT_NAME=admin" >> /home/stack/admin_auth
echo "export OSP_AUTH_URL=$(openstack endpoint list | grep keystone | awk '/public/ {print $14}')" >> /home/stack/admin_auth
echo "export OS_PASSWORD=$(grep undercloud_admin_password /home/stack/undercloud-passwords.conf | awk '{print $2}')" >> >> /home/stack/admin_auth
