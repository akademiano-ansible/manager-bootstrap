#!/bin/bash

#default values
DEF_LOCAL_CONFIG_REPO=""
DEF_AKADEMIANO_REPO="https://github.com/akademiano-ansible/ansible-app.git"
DATE=`date +%Y-%m-%d`
DEF_ANSIBLE_DIR="ansible-$DATE"

ME=`basename $0`
function print_help() {
    echo "Настройка Ansible"
    echo
    echo "Использование: $ME options..."
    echo "Параметры:"
    echo "  -a          akademiano library repo url"
    echo "  -l          local repo url"
    echo "  -d          ansible dir name"
    echo
}

while getopts ":a:l:d:h" opt ;
do
    case $opt in
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

#applay defaults
if [ -z "$AKADEMIANO_REPO" ]  || [ "$AKADEMIANO_REPO"=="!" ]; then
  AKADEMIANO_REPO="$DEF_AKADEMIANO_REPO"
fi
if [ -z "$LOCAL_CONFIG_REPO" ] || [ "$LOCAL_CONFIG_REPO"=="!" ]; then
  LOCAL_CONFIG_REPO="$DEF_LOCAL_CONFIG_REPO"
fi
if [ -z "$ANSIBLE_DIR" ] || [ "$ANSIBLE_DIR"=="!" ]; then
  ANSIBLE_DIR="$DEF_ANSIBLE_DIR"
fi

#check vars
[ -z "$AKADEMIANO_REPO" ] && { echo "Error: not defined AKADEMIANO_REPO"; exit 1; }
[ -z "$ANSIBLE_DIR" ] && { echo "Error: not defined ANSIBLE_DIR"; exit 1; }

#check dir not exist or empty
if [ -d "$ANSIBLE_DIR" ]; then
  if [ "$(ls -A $ANSIBLE_DIR)" ]; then
     echo "Directory $ANSIBLE_DIR exist and not empty"
     echo "Exit"
     exit 1
  fi
fi

####### prepare dirs structure in home dir
mkdir $ANSIBLE_DIR
cd $ANSIBLE_DIR
mkdir {app,bin,data,local}

#clone git akademiano and local
git clone -q $AKADEMIANO_REPO app/akademiano

if [ ! -z "$LOCAL_CONFIG_REPO" ]; then
  git clone -q $LOCAL_CONFIG_REPO local
fi

####### prepare local
cd local
if [ ! -e "ansible.cfg" ]; then
  ln -s ../app/akademiano/ansible.cfg
fi
if [ ! -e "requirements.yml" ]; then
  ln -s ../app/akademiano/requirements.yml
fi

if [ ! -d vars ]; then
  mkdir -p vars/{group_vars,host_vars}
fi

if [ ! -d playbooks ]; then
  mkdir playbooks
fi

cd playbooks
ln -s ../../app/akademiano/playbooks/akademiano-*.yml ./
ln -s ../vars/group_vars
ln -s ../vars/host_vars
cd ../

if [ ! -d inventory ]; then
  mkdir inventory
fi

cd inventory
ln -s ../../app/akademiano/inventory/__akademiano-*.yml ./
#ln -s ../../app/akademiano/inventory/akademiano-*.yml ./
cd ../

if [ ! -f .gitignore ]; then
  echo "playbooks/akademiano-*.yml" >> .gitignore
  echo "playbooks/group_vars" >> .gitignore
  echo "playbooks/host_vars" >> .gitignore
  echo "inventory/__akademiano-*.yml" >> .gitignore
  echo "ansible.cfg"  >> .gitignore
  echo "requirements.yml" >> .gitignore
fi

if [ ! -d .git ]; then
    git init > /dev/null
    git add . > /dev/null
fi
cd ../

####### prepare bin
cd bin

#configs
ln -s ../local/ansible.cfg
ln -s ../local/requirements.yml
ln -s ../local/inventory/
ln -s ../local/playbooks/

cd ../

echo "Ansible manager initialized. DONE. Exit"

exit 0
