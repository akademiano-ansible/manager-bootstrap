#!/bin/bash

if [[ $(id -u) -ne 0 ]]; 
  then echo "Ubuntu dev bootstrapper, APT-GETs all the things -- run as root...";
  exit 1; 
fi

echo "Update and upgrade all the things..."

apt-get update -y

#install default ansible version and wget
apt-get install ansible wget python-pip

#install ansible bootstrap role
ansible-galaxy install mrdatamapper.akademiano_ansible_bootstrap --roles-path=/etc/ansible/roles

#install ansible-toolbox
pip install git+https://github.com/larsks/ansible-toolbox

#run ansible bootstrap playbook
ansible-role mrdatamapper.akademiano_ansible_bootstrap -i localhost, --connection=local

exit 0;
