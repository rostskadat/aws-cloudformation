#!/bin/bash

# I redirect all the logs to a monitorized file
exec > >(tee -a "/var/log/playbook.log") 2> >(tee -a "/var/log/playbook.log")

ansible-playbook --extra-vars=@/root/playbooks/group_vars/stack.yaml --skip-tags "cleanup" "$1"