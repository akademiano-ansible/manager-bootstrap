#!/bin/bash

set -e

ME=`basename $0`
function print_help() {
    echo "Настройка Ansible"
    echo
    echo "Использование: $ME options..."
    echo "Параметры:"
    echo "  -u          ansible first user"
    echo "  -a          akademiano repo lib url"
    echo "  -l          local repo lib url"
    echo "  -h          print help"
    echo
}

#empty values
AKADEMIANO_REPO=""
LOCAL_CONFIG_REPO=""
FIRST_USER=""

while getopts ":a:l:u:h" opt ;
do
    case $opt in
        a) AKADEMIANO_REPO=$OPTARG;
            ;;
        l) LOCAL_CONFIG_REPO=$OPTARG;
            ;;
        u) FIRST_USER=$OPTARG;
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
apt-get install ansible curl wget ca-certificates git jq  mc nano -y

#update certificates for wget
update-ca-certificates

#download bootstrap playbook
wget -O bootstrap-ansible-prepare.yml https://raw.githubusercontent.com/akademiano-ansible/manager-bootstrap/master/bootstrap-ansible-prepare.yml
wget -O bootstrap-ansible-run.yml https://raw.githubusercontent.com/akademiano-ansible/manager-bootstrap/master/bootstrap-ansible-run.yml
wget -O configure-ansible-manager.yml https://raw.githubusercontent.com/akademiano-ansible/manager-bootstrap/master/configure-ansible-manager.yml

#run playbooks
ansible-playbook bootstrap-ansible-prepare.yml -vv
ansible-playbook bootstrap-ansible-run.yml -vv

EXTVARS=$(printf '{"ext_ansible_lib_repo":"%s","ext_ansible_local_repo":"%s","ext_ansible_first_manager":"%s"}\n' "$AKADEMIANO_REPO" "$LOCAL_CONFIG_REPO" "$FIRST_USER" | jq -c .)

ansible-playbook configure-ansible-manager.yml -vv  --extra-vars $EXTVARS

echo "Workstation initialized. DONE"

exit 0
