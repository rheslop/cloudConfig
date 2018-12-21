jq . << EOF > ~/instackenv.json
{
  "ssh-user": "undercloud",
  "ssh-key": "$(cat /home/stack/.ssh/id_rsa)",
  "power_manager": "nova.virt.baremetal.virtual_power_driver.VirtualPowerManager",
  "arch": "x86_64",
  "nodes": [
    {
      "name": "controller-1",
      "mac": ["52:54:81:00:a0:01"],
      "cpu": "2",
      "memory": "8192",
      "disk": "70",
      "pm_type": "pxe_ssh",
      "pm_addr": "192.168.0.84",
      "pm_user": "undercloud",
      "pm_password": "$(cat /home/stack/.ssh/id_rsa)",
      "capabilities": "node:controller-0,boot_option:local"
    },
    {
      "name": "controller-2",
      "mac": ["52:54:81:00:a0:02"],
      "cpu": "2",
      "memory": "8192",
      "disk": "70",
      "pm_type": "pxe_ssh",
      "pm_addr": "192.168.0.84",
      "pm_user": "undercloud",
      "pm_password": "$(cat /home/stack/.ssh/id_rsa)",
      "capabilities": "node:controller-1,boot_option:local"
    },
    {
      "name": "controller-3",
      "mac": ["52:54:81:00:a0:03"],
      "cpu": "2",
      "memory": "8192",
      "disk": "70",
      "pm_type": "pxe_ssh",
      "pm_addr": "192.168.0.84",
      "pm_user": "undercloud",
      "pm_password": "$(cat /home/stack/.ssh/id_rsa)",
      "capabilities": "node:controller-2,boot_option:local"
    },
    {
      "name": "compute-1",
      "mac": ["52:54:81:01:a0:01"],
      "cpu": "2",
      "memory": "8192",
      "disk": "100",
      "pm_type": "pxe_ssh",
      "pm_addr": "192.168.0.84",
      "pm_user": "undercloud",
      "pm_password": "$(cat /home/stack/.ssh/id_rsa)",
      "capabilities": "node:compute-0,boot_option:local"
    },
    {
      "name": "compute-2",
      "mac": ["52:54:81:01:a0:02"],
      "cpu": "2",
      "memory": "8192",
      "disk": "100",
      "pm_type": "pxe_ssh",
      "pm_addr": "192.168.0.84",
      "pm_user": "undercloud",
      "pm_password": "$(cat /home/stack/.ssh/id_rsa)",
      "capabilities": "node:compute-1,boot_option:local"
    }
  ]
}
EOF
