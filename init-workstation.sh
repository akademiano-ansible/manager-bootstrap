#!/bin/bash

set -e

ME=`basename $0`
function print_help() {
    echo "Настройка Ansible"
    echo
    echo "Использование: $ME options..."
    echo "Параметры:"
    echo "  -u          ansible first user"
    echo "  -g          ansible group"
    echo "  -a          akademiano library repo url"
    echo "  -l          local repo url"
    echo "  -d          ansible dir name"
    echo
}

# Если скрипт запущен без аргументов, открываем справку.
if [ $# = 0 ]; then
    print_help
    exit 1
fi

#empty values
AKADEMIANO_REPO="!"
LOCAL_CONFIG_REPO="!"
ANSIBLE_DIR_NAME="!"

ANSIBLE_MANAGER_GROUP="ansible-manager"

while getopts ":u:a:l:d:h" opt ;
do
    case $opt in
        a) AKADEMIANO_REPO=$OPTARG;
            ;;
        l) LOCAL_CONFIG_REPO=$OPTARG;
            ;;
        d) ANSIBLE_DIR_NAME=$OPTARG;
            ;;
        u) ANSIBLE_DIR_NAME=$OPTARG;
            ;;
        g) ANSIBLE_DIR_NAME=$OPTARG;
            ;;
            
        h) print_help
            exit 1
            ;;
        *) echo "Неправильный параметр";
            echo "Для вызова справки запустите $ME -h";
            exit 1
            ;;
        esac
done

if [[ $(id -u) -ne 0 ]];
  then echo "Please run as root!"
  exit 1
fi

[ -z "$ANSIBLE_USER" ] && { echo "Error: not defined ansible manager user name (-u)"; exit 1; }

echo "Update and upgrade all the things..."

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
apt-get install ansible wget ca-certificates git -y

#update certificates for wget
update-ca-certificates

#download bootstrap playbook
wget -O bootstrap-ansible-prepare.yml https://raw.githubusercontent.com/akademiano-ansible/manager-bootstrap/master/bootstrap-ansible-prepare.yml
wget -O bootstrap-ansible-run.yml https://raw.githubusercontent.com/akademiano-ansible/manager-bootstrap/master/bootstrap-ansible-run.yml

#run playbooks
ansible-playbook bootstrap-ansible-prepare.yml -vv
ansible-playbook bootstrap-ansible-run.yml -vv
#second run after update ansible
ansible-playbook bootstrap-ansible-run.yml -vv

echo "Workstation initialized DONE"



#cd $USER_DIR;
#wget -O init-manager.sh https://raw.githubusercontent.com/akademiano-ansible/manager-bootstrap/master/init-manager.sh
#chmod +x init-manager.sh
#sudo -E -H -i -u $ANSIBLE_USER $USER_DIR/init-manager.sh -a $AKADEMIANO_REPO -l $LOCAL_CONFIG_REPO -d $ANSIBLE_DIR_NAME

#echo "All DONE. Exit"

exit 0
