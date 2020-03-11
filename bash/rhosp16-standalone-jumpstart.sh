#!/bin/bash

if [ -f ./rhosp16-standalone.conf ]; then
	source ./rhosp16-standalone.conf
fi

if [ ! -f /etc/sysconfig/network-scripts/ifcfg-eth1 ]; then
	echo -e "\E[0;31meth1 not found!:\E[0m"
	exit 1
fi 

if [ -z ${SUBMAN_USER} ]; then
        read -p "subscription-manager username: " SUBMAN_USER
fi

if [ -z ${SUBMAN_PASS} ]; then
        read -s -p "subscription-manager password: " SUBMAN_PASS
fi

if [ -z ${SUBMAN_POOL} ]; then
	read -p "subscription-manager pool: " SUBMAN_POOL
fi

if [ -z ${IP_ADDRESS} ]; then
	read -p "eth1 IP address: " IP_ADDRESS
fi

function CONFIGURE_HOST {


cat <<EOF > /etc/sysconfig/network-scripts/ifcfg-eth1
DEVICE="eth1"
BOOTPROTO="none"
ONBOOT="yes"
TYPE="Ethernet"
USERCTL="yes"
IPADDR="${IP_ADDRESS}"
NETMASK="255.255.255.0"
EOF

ifup eth1


subscription-manager register --username ${SUBMAN_USER} --password ${SUBMAN_PASS}
subscription-manager attach --pool=${SUBMAN_POOL}
subscription-manager repos --disable=*
subscription-manager repos \
--enable=rhel-8-for-x86_64-baseos-rpms \
--enable=rhel-8-for-x86_64-appstream-rpms \
--enable=rhel-8-for-x86_64-highavailability-rpms \
--enable=ansible-2.8-for-rhel-8-x86_64-rpms \
--enable=openstack-16-for-rhel-8-x86_64-rpms \
--enable=fast-datapath-for-rhel-8-x86_64-rpms

dnf install -y python3-tripleoclient tmux git
dnf -y update

}


function PREINSTALL_CHECKLIST {
useradd stack
echo 'stack' | passwd --stdin stack
echo 'stack ALL=(root) NOPASSWD:ALL' | tee -a /etc/sudoers.d/stack
chmod 0440 /etc/sudoers.d/stack

mkdir /home/stack/templates
mkdir /home/stack/images

cat <<EOF > /home/stack/templates/role.yaml
###############################################################################
# Role: Standalone                                                            #
###############################################################################
- name: Standalone
  description: |
    A standalone role that a minimal set of services. This can be used for
    testing in a single node configuration with the
    'openstack tripleo deploy --standalone' command or via an Undercloud using
    'openstack overcloud deploy'.
  CountDefault: 1
  tags:
    - primary
    - controller
    - standalone
  networks:
    External:
      subnet: external_subnet
    InternalApi:
      subnet: internal_api_subnet
    Storage:
      subnet: storage_subnet
    StorageMgmt:
      subnet: storage_mgmt_subnet
    Tenant:
      subnet: tenant_subnet
  ServicesDefault:
    - OS::TripleO::Services::Aide
    - OS::TripleO::Services::AodhApi
    - OS::TripleO::Services::AodhEvaluator
    - OS::TripleO::Services::AodhListener
    - OS::TripleO::Services::AodhNotifier
    - OS::TripleO::Services::AuditD
    - OS::TripleO::Services::BarbicanApi
    - OS::TripleO::Services::BarbicanBackendDogtag
    - OS::TripleO::Services::BarbicanBackendKmip
    - OS::TripleO::Services::BarbicanBackendPkcs11Crypto
    - OS::TripleO::Services::BarbicanBackendSimpleCrypto
    - OS::TripleO::Services::CACerts
    - OS::TripleO::Services::CeilometerAgentCentral
    - OS::TripleO::Services::CeilometerAgentNotification
    - OS::TripleO::Services::CertmongerUser
    - OS::TripleO::Services::CinderApi
    - OS::TripleO::Services::CinderBackendNVMeOF
    - OS::TripleO::Services::CinderBackendPure
    - OS::TripleO::Services::CinderBackup
    - OS::TripleO::Services::CinderScheduler
    - OS::TripleO::Services::CinderVolume
    - OS::TripleO::Services::Clustercheck
    - OS::TripleO::Services::Collectd
    - OS::TripleO::Services::ComputeCeilometerAgent
    - OS::TripleO::Services::ContainerImagePrepare
    - OS::TripleO::Services::ContainersLogrotateCrond
    - OS::TripleO::Services::DesignateApi
    - OS::TripleO::Services::DesignateCentral
    - OS::TripleO::Services::DesignateMDNS
    - OS::TripleO::Services::DesignateProducer
    - OS::TripleO::Services::DesignateSink
    - OS::TripleO::Services::DesignateWorker
    - OS::TripleO::Services::Docker
    - OS::TripleO::Services::DockerRegistry
    - OS::TripleO::Services::Ec2Api
    - OS::TripleO::Services::Etcd
    - OS::TripleO::Services::ExternalSwiftProxy
    - OS::TripleO::Services::GlanceApi
    - OS::TripleO::Services::GnocchiApi
    - OS::TripleO::Services::GnocchiMetricd
    - OS::TripleO::Services::GnocchiStatsd
    - OS::TripleO::Services::HAproxy
    - OS::TripleO::Services::HeatApi
    - OS::TripleO::Services::HeatApiCfn
    - OS::TripleO::Services::HeatApiCloudwatch
    - OS::TripleO::Services::HeatEngine
    - OS::TripleO::Services::Horizon
    - OS::TripleO::Services::IpaClient
    - OS::TripleO::Services::Ipsec
    - OS::TripleO::Services::IronicApi
    - OS::TripleO::Services::IronicConductor
    - OS::TripleO::Services::IronicInspector
    - OS::TripleO::Services::IronicNeutronAgent
    - OS::TripleO::Services::IronicPxe
    - OS::TripleO::Services::Iscsid
    - OS::TripleO::Services::Keepalived
    - OS::TripleO::Services::Kernel
    - OS::TripleO::Services::Keystone
    - OS::TripleO::Services::LoginDefs
    - OS::TripleO::Services::ManilaApi
    - OS::TripleO::Services::ManilaScheduler
    - OS::TripleO::Services::ManilaShare
    - OS::TripleO::Services::MasqueradeNetworks
    - OS::TripleO::Services::Memcached
    - OS::TripleO::Services::MetricsQdr
    - OS::TripleO::Services::MistralApi
    - OS::TripleO::Services::MistralEngine
    - OS::TripleO::Services::MistralEventEngine
    - OS::TripleO::Services::MistralExecutor
    - OS::TripleO::Services::Multipathd
    - OS::TripleO::Services::MySQL
    - OS::TripleO::Services::MySQLClient
    - OS::TripleO::Services::NeutronApi
    - OS::TripleO::Services::NeutronBgpVpnApi
    - OS::TripleO::Services::NeutronBgpVpnBagpipe
    - OS::TripleO::Services::NeutronCorePlugin
    - OS::TripleO::Services::NeutronDhcpAgent
    - OS::TripleO::Services::NeutronL2gwAgent
    - OS::TripleO::Services::NeutronL2gwApi
    - OS::TripleO::Services::NeutronL3Agent
    - OS::TripleO::Services::NeutronLinuxbridgeAgent
    - OS::TripleO::Services::NeutronMetadataAgent
    - OS::TripleO::Services::NeutronOvsAgent
    - OS::TripleO::Services::NeutronSfcApi
    - OS::TripleO::Services::NeutronVppAgent
    - OS::TripleO::Services::NovaApi
    - OS::TripleO::Services::NovaCompute
    - OS::TripleO::Services::NovaConductor
    - OS::TripleO::Services::NovaIronic
    - OS::TripleO::Services::NovaLibvirt
    - OS::TripleO::Services::NovaMetadata
    - OS::TripleO::Services::NovaMigrationTarget
    - OS::TripleO::Services::NovaScheduler
    - OS::TripleO::Services::NovaVncProxy
    - OS::TripleO::Services::OVNController
    - OS::TripleO::Services::OVNDBs
    - OS::TripleO::Services::OVNMetadataAgent
    - OS::TripleO::Services::OctaviaApi
    - OS::TripleO::Services::OctaviaDeploymentConfig
    - OS::TripleO::Services::OctaviaHealthManager
    - OS::TripleO::Services::OctaviaHousekeeping
    - OS::TripleO::Services::OctaviaWorker
    - OS::TripleO::Services::OpenStackClients
    - OS::TripleO::Services::OsloMessagingNotify
    - OS::TripleO::Services::OsloMessagingRpc
    - OS::TripleO::Services::Pacemaker
    - OS::TripleO::Services::PankoApi
    - OS::TripleO::Services::PlacementApi
    - OS::TripleO::Services::Podman
    - OS::TripleO::Services::Rear
    - OS::TripleO::Services::Redis
    - OS::TripleO::Services::Rhsm
    - OS::TripleO::Services::Rsyslog
    - OS::TripleO::Services::RsyslogSidecar
    - OS::TripleO::Services::SaharaApi
    - OS::TripleO::Services::SaharaEngine
    - OS::TripleO::Services::Securetty
    - OS::TripleO::Services::Snmp
    - OS::TripleO::Services::Sshd
    - OS::TripleO::Services::SwiftDispersion
    - OS::TripleO::Services::SwiftProxy
    - OS::TripleO::Services::SwiftRingBuilder
    - OS::TripleO::Services::SwiftStorage
    - OS::TripleO::Services::Timesync
    - OS::TripleO::Services::Timezone
    - OS::TripleO::Services::Tmpwatch
    - OS::TripleO::Services::TripleoFirewall
    - OS::TripleO::Services::TripleoPackages
    - OS::TripleO::Services::Tuned
    - OS::TripleO::Services::Vpp
    - OS::TripleO::Services::Zaqar
EOF

cat <<EOF > /home/stack/templates/standalone.yaml
parameter_defaults:
  ContainerImagePrepare:
  - set:
      name_prefix: openstack-
      name_suffix: ''
      namespace: registry.redhat.io/rhosp-rhel8
      neutron_driver: ovn
      rhel_containers: false
      tag: '16.0'
    tag_from_label: '{version}-{release}'
  ContainerImageRegistryCredentials:
    registry.redhat.io:
      ${SUBMAN_USER}: "${SUBMAN_PASS}"
  CloudName: ${IP_ADDRESS}
  ControlPlaneStaticRoutes: []
  Debug: true
  DeploymentUser: stack
  DnsServers:
    - 192.168.80.254
    - 192.168.100.1
  DockerInsecureRegistryAddress:
    - 192.168.100.4:8787
  NeutronPublicInterface: eth1
  NeutronBridgeMappings: datacentre:br-ctlplane
  NeutronPhysicalBridge: br-ctlplane
  StandaloneEnableRoutedNetworks: false
  StandaloneHomeDir: /home/stack
  StandaloneLocalMtu: 1500
  StandaloneExtraConfig:
    NovaComputeLibvirtType: qemu
  NtpServer: 0.pool.ntp.org
  # Domain
  NeutronDnsDomain: ootpa.local
  CloudDomain: ootpa.local
  CloudName: overcloud.ootpa.local
  CloudNameCtlPlane: overcloud.ctlplane.ootpa.local
  CloudNameInternal: overcloud.internalapi.ootpa.local
  CloudNameStorage: overcloud.storage.ootpa.local
  CloudNameStorageManagement: overcloud.storagemgmt.ootpa.local

EOF

TEMPLATES_HOME=/usr/share/openstack-tripleo-heat-templates
CUSTOM_TEMPLATES=/home/stack/templates

cat <<EOF > /home/stack/deploy.sh

#!/bin/bash


sudo podman login registry.redhat.io --username ${SUBMAN_USER} --password ${SUBMAN_PASS}

sudo openstack tripleo deploy --templates \
--local-ip=${IP_ADDRESS}/24 \
-e ${TEMPLATES_HOME}/environments/standalone/standalone-tripleo.yaml \
-r ${CUSTOM_TEMPLATES}/role.yaml \
-e ${CUSTOM_TEMPLATES}/standalone.yaml \
--output-dir /home/stack --standalone

EOF

chown -R stack:stack /home/stack

} 


function DEPLOY {
su --command 'tmux new-session -d -s "deploy" /home/stack/deploy.sh' stack

}



CONFIGURE_HOST
PREINSTALL_CHECKLIST
# DEPLOY
