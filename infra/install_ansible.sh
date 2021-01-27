#!/bin/sh

set -x

apt-update
apt install -y ansible \
               net-tools \
               python3-pip

# Single machine will simulate multiple hosts
sed -i 's/^127.0.0.1.*/\0 foo.example.com bar.example.com one.example.com two.example.com three.example.com/' /etc/hosts

# Ensure that host can ssh to itself
ssh-keygen -t rsa -f ~/.ssh/id_rsa_ansible_manager -q -N ""
cat ~/.ssh/id_rsa_ansible_manager.pub >> ~/.ssh/authorized_keys
cat << EOF >> ~/.ssh/config
IdentityFile ~/.ssh/id_rsa_ansible_manager
StrictHostKeyChecking no
UserKnownHostsFile /dev/null
EOF

adduser --disabled-password --gecos "" devops

apt update
apt install -y docker.io
systemctl enable docker.service

sudo curl -L "https://github.com/docker/compose/releases/download/1.27.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

pip3 install docker compose docker-compose

git clone https://github.com/ansible/awx.git
git clone

wall "Bootstrap ready"
