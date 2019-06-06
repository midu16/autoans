#!/bin/bash
# Mihai IDU

echo "###################################################################################"
echo " This script is gonna run a set of checks of a specific machine or set of machines!"
ORIGINAL_PATH=$PWD
LOG_DIR=$ORIGINAL_PATH/logs
PLAYBOOK_DIR=$ORIGINAL_PATH/playbooks
UPTIME_DIR=$PLAYBOOK_DIR/uptime

echo " Running the checks..."
echo " Please wait! The results log will be flushed in the $LOG_DIR!"
ansible-playbook $UPTIME_DIR/uptime.yaml > $LOG_DIR/uptime.log 2>&1

echo " Flushing the UPTIME log results!"
sleep 2s
cat $LOG_DIR/uptime.log
echo "###################################################################################"

