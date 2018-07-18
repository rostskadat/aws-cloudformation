#!/bin/bash

echo "Are you sure you want to cleanup and start over?"
echo "This will erase everything and is not recoverable!"
echo ""
echo "Press Enter to continue, Ctrl-C to quit"
read line

ansible-playbook /root/playbooks/cleanup.yaml --extra-vars=@/root/playbooks/group_vars/stack.yaml
