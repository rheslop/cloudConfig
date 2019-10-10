jq . << EOF > ~/instackenv.json
{
  "nodes": [
    {
      "name": "controller-1",
      "mac": ["52:54:81:00:a0:01"],
      "cpu": "2",
      "memory": "8192",
      "disk": "70",
      "pm_type": "ipmi",
      "pm_addr": "192.168.0.84",
      "pm_port": "6211",
      "pm_user": "admin",
      "pm_password": "password",
      "capabilities": "node:controller-0,boot_option:local"
    },
    {
      "name": "controller-2",
      "mac": ["52:54:81:00:a0:02"],
      "cpu": "2",
      "memory": "8192",
      "disk": "70",
      "pm_type": "ipmi",
      "pm_addr": "192.168.0.84",
      "pm_port": "6212",
      "pm_user": "admin",
      "pm_password": "password",
      "capabilities": "node:controller-1,boot_option:local"
    },
    {
      "name": "controller-3",
      "mac": ["52:54:81:00:a0:03"],
      "cpu": "2",
      "memory": "8192",
      "disk": "70",
      "pm_type": "ipmi",
      "pm_addr": "192.168.0.84",
      "pm_port": "6213",
      "pm_user": "admin",
      "pm_password": "password",
      "capabilities": "node:controller-2,boot_option:local"
    },
    {
      "name": "compute-1",
      "mac": ["52:54:81:01:a0:01"],
      "cpu": "2",
      "memory": "8192",
      "disk": "100",
      "pm_type": "ipmi",
      "pm_addr": "192.168.0.84",
      "pm_port": "6231",
      "pm_user": "admin",
      "pm_password": "password",
      "capabilities": "node:compute-0,boot_option:local"
    },
    {
      "name": "compute-2",
      "mac": ["52:54:81:01:a0:02"],
      "cpu": "2",
      "memory": "8192",
      "disk": "100",
      "pm_type": "ipmi",
      "pm_addr": "192.168.0.84",
      "pm_port": "6232",
      "pm_user": "admin",
      "pm_password": "password",
      "capabilities": "node:compute-1,boot_option:local"
    }
  ]
}
EOF
