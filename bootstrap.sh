#!/bin/bash

if [[ $(id -u) -ne 0 ]];
  then echo "Ubuntu dev bootstrapper, APT-GETs all the things -- run as root...";
  exit 1;
fi

echo "Update and upgrade all the things..."

service snapd stop

mv /etc/apt/apt.conf.d/99update-notifier /root/99update-notifier

apt-get update -y

DEBIAN_FRONTEND=noninteractive \
apt-get \
-o Dpkg::Options::="--force-confnew" \
-fuy \
upgrade

DEBIAN_FRONTEND=noninteractive \
apt-get \
-o Dpkg::Options::="--force-confnew" \
-fuy \
dist-upgrade

#install default ansible version and wget
apt-get install ansible wget ca-certificates

#update certificates for wget
update-ca-certificates

#download bootstrap playbook
wget -O ansible-bootstrap-1.yml https://raw.githubusercontent.com/akademiano-ansible/linux-bootstrap/master/ansible-bootstrap-1.yml
wget -O ansible-bootstrap-2.yml https://raw.githubusercontent.com/akademiano-ansible/linux-bootstrap/master/ansible-bootstrap-2.yml

ansible-playbook ansible-bootstrap-1.yml -vv

ansible-playbook ansible-bootstrap-2.yml -vv

wget -O ansible-roles-preload.yml https://raw.githubusercontent.com/akademiano-ansible/linux-bootstrap/master/ansible-roles-preload.yml

ansible-playbook ansible-roles-preload.yml -vv

#if not exist param with default roles-install playbook url - use akademiano-full

ROLES_URL=https://gist.githubusercontent.com/mrdatamapper/75fbd48ab24c7e4509cc1ca6122a1d0d/raw/akademiano-ansible-roles-all.yml

wget -O ansible-roles-install.yml $ROLES_URL

ansible-playbook ansible-roles-install.yml -vv

mv /root/99update-notifier /etc/apt/apt.conf.d/99update-notifier

exit 0;
