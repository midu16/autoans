#!/bin/bash
####################################################################################################################
# This scrip is going to prepare the Ubuntu16.04 environment as a AnsibleMachine
# Mihai IDU - 2019
# 
#
####################################################################################################################
echo "###############################################################################################################"
echo " First we will prepare the Ubuntu environment!"
echo ""
sudo apt-get update -y
sudo apt-get upgrade -y
echo ""
sleep 2s
echo " It will prepare the python environment and python-pip to the latest version!"
./checkpackage.sh python3
./checkpackage.sh python-pip
echo " Upgrade the Python-pip to the latest version in order to install all the pip libraries needed for Ansible!"
pip install --upgrade pip
pip install ansible

echo "###############################################################################################################"
echo " Preparing the ssh keys of the Ansible Machine!"
sleep 2s
ssh-keygen
# commented those lines to create a recursivity of the process
#echo " Please, input the user of the targeted host to push the ssh key."
#read HOSTUSER
#echo " Please, input the IP address of the targeted host."
#read HOSTIP
#echo " Please, input the hostname of the targeted host."
#read HOSTNAME
#sh-copy-id -i ~/.ssh/id_rsa.pub $HOSTUSER@$HOSTIP
echo " Installing the ansible software solution!"
sudo apt-add-repository ppa:ansible/ansible -y
sudo apt-get update -y
sudo apt-get upgrade -y
./checkpackage.sh ansible 
echo " The Ansible tower it has been installed!"
echo "###############################################################################################################"
####################################################################################################################
# This section should configure the AnsibleHost with the N Host Targets 
# All the informations for each target host is gather from keyboard
#
####################################################################################################################
# creating for-loop to create more 
#
# echo " Input a Number:"
#read N
#for ((index=1;index<=$N;index++))
#do
#        echo "input a hostname for each test node:"
#        echo " "
#        read HOSTNAME
#        echo "$HOSTNAME[$index]"
#done
#echo $HOSTNAME
#####################################################################################################################
echo " Please, input the USER of the targeted host to push the ssh key."
read HOSTUSER
echo " Please, input the IP address of the targeted host."
read HOSTIP
echo " Please, input the HOSTNAME of the targeted host."
read HOSTNAME
ssh-copy-id -i ~/.ssh/id_rsa.pub $HOSTUSER@$HOSTIP
echo " Check if it is needed to configure the targeted hosts in the Ansible configuration."
echo ""
echo " All the following configuration it will target the configuration of the ANSIBLE TOWER!"
echo ""
echo " Please, input the HOST's CATEGORY defined for the ansible tower."
read HOSTCATEGORY

# Switching to super-user priviledges in order to have access to push the configuration
#sudo su
#if [[ 'grep '$HOSTCATEGORY' /etc/ansible/hosts' ]];then
if grep -q $HOSTCATEGORY "/etc/ansible/hosts";then
        # Some Actions
        echo " The host's < $HOSTCATEGORY > category is already defined!"
else 
	echo " The host's category is not defined. This will be define as you requested!"
	sudo su -c "echo "[$HOSTCATEGORY]" >> /etc/ansible/hosts"
fi

if grep -q $HOSTNAME "/etc/ansible/hosts";then
	# Some Actions are needed-to be added here
	echo " The host's name: $HOSTNAME is already defined!"
else
	echo " The host's name: $HOSTNAME is not defined. This will be defines as you requested!"
	sudo su -c "echo "$HOSTNAME" >> /etc/ansible/hosts"
fi

echo " Creating the host variables files for configuration."
if [ ! -d /etc/ansible/host_vars ]; then
	# Control will enter here if host environment directory doesnt exists.
	sudo su -c "mkdir /etc/ansible/host_vars"
	echo " The Host Variable has been created!"
else 
	echo " The Host Variable exists! It wont be recreated!"
fi

echo " Now we are checking if the targeted host configuration file exists.If it exists, just update the information"
if [ ! -d /etc/ansible/hosts_vars/$HOSTNAME ]; then
	# Control will enter here if the host configuration file doesnt exists.
	sudo su -c "echo "ansible_ssh_host: $HOSTIP" >> /etc/ansible/host_vars/$HOSTNAME"
	sudo su -c "echo "ansible_ssh_port: 22" >> /etc/ansible/host_vars/$HOSTNAME"
	sudo su -c "echo "ansible_ssh_user: $HOSTUSER" >> /etc/ansible/host_vars/$HOSTNAME"
else
	echo " The Host Configuration file exists! It wont be recreated!"
fi
####################################################################################################################
# Exiting the super-user priviledges 
#exit
#
echo " "
echo " Testing the Ansible config"
ansible -m ping all
echo " Check if the targeted host available memory"
ansible -m shell -a 'free -m' $HOSTNAME

echo "###################################################################################"
echo " This script is gonna run a set of checks of a specific machine or set of machines!"
ORIGINAL_PATH=$PWD
LOG_DIR=$ORIGINAL_PATH/logs
PLAYBOOK_DIR=$ORIGINAL_PATH/playbooks
UPTIME_DIR=$PLAYBOOK_DIR/uptime
MEMORY_DIR=$PLAYBOOK_DIR/resource_check
echo " Running the checks..."
echo " Please wait! The results log will be flushed in the $LOG_DIR!"
ansible-playbook $UPTIME_DIR/uptime.yaml > $LOG_DIR/uptime.log 2>&1
#ansible-playbook $MEMORY_DIR/resource_check.yaml > $LOG_DIR/memory_check.log 2>&1
ansible all -m gather_facts --tree /tmp/facts > $LOG_DIR/facts.log 2>&1

echo " Flushing the UPTIME log results!"
sleep 2s
#cat $LOG_DIR/uptime.log
echo ""
#echo " Flushing the Available Percentage of MEMORY log results!"
#sleep 2s
#cat $LOG_DIR/memory_check.log

echo "###################################################################################"


echo "EOF"
echo "###############################################################################################################"

