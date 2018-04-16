CONTROLLER_1_NAME=
CONTROLLER_1_BMC=
CONTROLLER_1_LOGIN=
CONTROLLER_1_PASS=
CONTROLLER_2_NAME=
CONTROLLER_2_BMC=
CONTROLLER_2_LOGIN=
CONTROLLER_2_PASS=
CONTROLLER_3_NAME=
CONTROLLER_3_BMC=
CONTROLLER_3_LOGIN=
CONTROLLER_3_PASS=

sudo pcs stonith create ipmilan-for-ctl01 fence_ipmilan pcmk_host_list=${CONTROLLER_1_NAME} ipaddr=$CONTROLLER_1_BMC login=$CONTROLLER_1_LOGIN passwd=$CONTROLLER_1_PASS lanplus=1 cipher=1 op monitor interval=60s
sudo pcs constraint location ipmilan-for-ctl01 avoids $CONTROLLER_1_NAME
sudo pcs stonith create ipmilan-for-ctl02 fence_ipmilan pcmk_host_list=${CONTROLLER_2_NAME} ipaddr=$CONTROLLER_2_BMC login=$CONTROLLER_2_LOGIN passwd=$CONTROLLER_2_PASS lanplus=1 cipher=1 op monitor interval=60s
sudo pcs constraint location ipmilan-for-ctl02 avoids $CONTROLLER_2_NAME
sudo pcs stonith create ipmilan-for-ctl03 fence_ipmilan pcmk_host_list=${CONTROLLER_3_NAME} ipaddr=$CONTROLLER_3_BMC login=$CONTROLLER_3_LOGIN passwd=$CONTROLLER_3_PASS lanplus=1 cipher=1 op monitor interval=60s
sudo pcs constraint location ipmilan-for-ctl03 avoids $CONTROLLER_3_NAME
