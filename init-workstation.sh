#!/bin/bash

set -e

ME=`basename $0`
function print_help() {
    echo "Настройка Ansible"
    echo
    echo "Использование: $ME options..."
    echo "Параметры:"
    echo "  -u          ansible manager user name"
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
AKADEMIANO_REPO="-"
LOCAL_CONFIG_REPO="-"
ANSIBLE_DIR_NAME="-"

while getopts ":u:a:l:d:h" opt ;
do
    case $opt in
        u)  ANSIBLE_USER=$OPTARG;
            ;;
        a) AKADEMIANO_REPO=$OPTARG;
            ;;
        l) LOCAL_CONFIG_REPO=$OPTARG;
            ;;
        d) ANSIBLE_DIR_NAME=$OPTARG;
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

[ -z "ANSIBLE_USER" ] && { echo "Error: not defined ansible manager user name (-u)"; exit 1; }


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
apt-get install ansible wget ca-certificates -y

#update certificates for wget
update-ca-certificates

#download bootstrap playbook
wget -O bootstrap-ansible-prepare.yml https://raw.githubusercontent.com/akademiano-ansible/manager-bootstrap/master/bootstrap-ansible-prepare.yml
wget -O bootstrap-ansible-run.yml https://raw.githubusercontent.com/akademiano-ansible/manager-bootstrap/master/bootstrap-ansible-run.yml

#run playbooks
ansible-playbook bootstrap-ansible-prepare.yml -vv
ansible-playbook bootstrap-ansible-run.yml -vv

#run on user
$USER_DIR=$(sudo -u $ANSIBLE_USER -H -s eval 'echo $HOME')
cd $USER_DIR;
wget -o init-manager.sh https://raw.githubusercontent.com/akademiano-ansible/manager-bootstrap/master/init-manager.sh
sudo -u $ANSIBLE_USER "$USER_DIR/init-manager.sh -a $AKADEMIANO_REPO -l $LOCAL_CONFIG_REPO -d $ANSIBLE_DIR_NAME"

exit 0
