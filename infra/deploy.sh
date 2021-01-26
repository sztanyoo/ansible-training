#!/bin/bash

set -e

if [ ! -e id_rsa_ansible ]
then
  ssh-keygen -t rsa -f id_rsa_ansible -q -N ""
fi

if [ "x" = "${VULTR_API_KEY}x" ]
then
  echo "Please set VULTR_API_KEY variable"
  exit 1
fi

terraform apply

MASTER_IP=$(terraform output server_ip)
echo "Server IP is $MASTER_IP"
echo "Create SSH config"

echo "Host ansible
  HostName $MASTER_IP
  User root
  IdentityFile `pwd`/id_rsa_ansible
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
" > ~/.ssh/config.d/ansible.conf