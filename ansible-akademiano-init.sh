#!/bin/bash

LOCAL_CONFIG_REPO=""
AKADEMIANO_REPO="https://github.com/akademiano-ansible/ansible-app.git"

#ansible dir name
ANSIBLE_DIR="ansible-new"

#input
if [ ! -z "$1" ] ; then
  LOCAL_CONFIG_REPO=$1
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
git clone $AKADEMIANO_REPO app/akademiano

if [ ! -z "$LOCAL_CONFIG_REPO" ]; then
  git clone $LOCAL_CONFIG_REPO local
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
    git init
    git add .
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

exit 0
