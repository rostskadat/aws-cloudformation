#!/bin/bash

# I redirect all the logs to a monitorized file
exec > >(tee -a "/var/log/playbook.log") 2> >(tee -a "/var/log/playbook.log")

playbook="$1"
Region="$2"
StackName="$3"
[ -z "$playbook" ] && echo "Invalid playbook" && exit 1

#[ -z "$Region" ] && echo "Invalid Region" && exit 1
#[ -z "$StackName" ] && echo "Invalid StackName" && exit 1


ansible-playbook --extra-vars=@/root/playbooks/group_vars/stack.yaml --skip-tags "cleanup" "$playbook"
rc=$?

if [ ! -z "$Region" ] && [ ! -z "$StackName" ]; then
    echo "Signaling as requested ($rc)"
    /root/signal_asg.sh $rc "$Region" "$StackName"
fi
exit $rc