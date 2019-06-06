#!/bin/bash
# This scrip is going to prepare the Ubuntu16.04 environment as a AnsibleMachine
# Mihai IDU - 2019

echo " Preparing the ssh keys of the Ansible Machine!"
sleep 2s
ssh-keygen

echo " Please, input the user of the targeted host to push the ssh key."
read HOSTUSER
echo " Please, input the IP address of the targeted host."
read HOSTIP
echo " Please, input the hostname of the targeted host."
read HOSTNAME

sh-copy-id -i ~/.ssh/id_rsa.pub $HOSTUSER@$HOSTIP

echo " Installing the ansible software solution!"
sudo apt-add-repository ppa:ansible/ansible -y
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install ansible -y
echo " The Ansible tower it has been installed!"


echo " Configuring the targeted hosts in the Ansible configuration."
echo "[servers]" >> /etc/ansible/hosts
echo "$HSOTNAME" >> /etc/ansible/hosts

echo " Creating the host variables files for configuration."
if [ ! -d /etc/ansible/host_vars ]; then
	# Control will enter here if host environment directory doesnt exists.
	sudo mkdir /etc/ansible/host_vars
	echo " The Host Variable has been created!"
fi 
echo " The Host Variable exists! It wont be recreated!"
echo " Now we are checking if the targeted host configuration file exists.If it exists, just update the information"
if [ ! -d /etc/ansible/hosts_vars/$HOSTNAME ]; then
	# Control will enter here if the host configuration file doesnt exists.
	echo "ansible_ssh_host: $HOSTIP" >> /etc/ansible/host_vars/$HOSTNAME
	echo "ansible_ssh_port: 22" >> /etc/ansible/host_vars/$HOSTNAME
	echo "ansible_ssh_user: $HOSTUSER" >> /etc/ansible/host_vars/$HOSTNAME
fi
echo " "
echo " Testing the Ansible config"
ansible -m ping all

echo " Check if the targeted host available memory"
ansible -m shell -a 'free -m' $HOSTNAME


echo "###############################################################################################################"

