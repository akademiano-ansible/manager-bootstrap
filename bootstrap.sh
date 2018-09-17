#!/bin/bash

if [[ $(id -u) -ne 0 ]]; 
  then echo "Ubuntu dev bootstrapper, APT-GETs all the things -- run as root...";
  exit 1; 
fi

echo "Update and upgrade all the things..."

apt-get update -y

#install default ansible version and wget
apt-get install ansible wget ca-certificates

#update certificates for wget
update-ca-certificates

#download bootstrap playbook
wget -O ansible-bootstrap.yml http://

ansible-playbook --connection=local 127.0.0.1 ansible-bootstrap.yml

wget -O ansible-roles-preload.yml http://

ansible-playbook --connection=local 127.0.0.1 ansible-roles-preload.yml

#if not exist param with default roles-install playbook url - use akademiano-full

ROLES_URL=

wget -O bootstrap-roles.yml http://

ansible-playbook --connection=local 127.0.0.1 bootstrap-roles.yml

exit 0;
