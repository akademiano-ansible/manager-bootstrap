#!/bin/bash

cd ~/ansible/bin

ansible-galaxy install --roles-path ~~/ansible/bin/roles/ -r requirements.yml

wget wget -O ansible-first-run.yml https://raw.githubusercontent.com/akademiano-ansible/manager-bootstrap/master/ansible-first-run.yml

ansible-playbook ansible-first-run.yml

exit 0
