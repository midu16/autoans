#!/bin/bash

if grep -q alabala "/etc/ansible/hosts";then
	# Some Actions
	echo "The file webserver category is already defined!"
fi
