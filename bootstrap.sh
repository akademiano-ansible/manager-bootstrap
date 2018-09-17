#!/bin/bash

if [[ $(id -u) -ne 0 ]];
  then echo "Ubuntu dev bootstrapper, APT-GETs all the things -- run as root...";
  exit 1;
fi

echo "Update and upgrade all the things..."

apt-get update -y

apt-get dist-upgrade -y

#install default ansible version and wget
apt-get install ansible wget ca-certificates

#update certificates for wget
update-ca-certificates

#download bootstrap playbook
wget -O ansible-bootstrap.yml https://raw.githubusercontent.com/akademiano-ansible/linux-bootstrap/master/ansible-bootstrap.yml

ansible-playbook ansible-bootstrap.yml

wget -O ansible-roles-preload.yml https://raw.githubusercontent.com/akademiano-ansible/linux-bootstrap/master/ansible-roles-preload.yml

ansible-playbook ansible-roles-preload.yml

#if not exist param with default roles-install playbook url - use akademiano-full

ROLES_URL=https://gist.githubusercontent.com/mrdatamapper/75fbd48ab24c7e4509cc1ca6122a1d0d/raw/a84c025dd08f739371d1758f2c0994294e161661/akademiano-ansible-roles-all.yml

wget -O ansible-roles-install.yml $ROLES_URL

ansible-playbook ansible-roles-install.yml

exit 0;
