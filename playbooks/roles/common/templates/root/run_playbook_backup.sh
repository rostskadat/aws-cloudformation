#!/bin/bash
#
# FILE: run_playbook_backup.sh
#
# DESCRIPTION: This command is in charge of calling the backup playbook.
#   The main automation entry point is accessible through the AWS System Manager console
#   (https://console.aws.amazon.com/systems-manager/documents). it is meant to ease the 
#   configuration of an existing instance. Follow these steps to execute this command
#
# - Open https://console.aws.amazon.com/systems-manager/run-command/executing-commands
# - Click on "Run Command"
# - Filters Documents by Owner: only display document "Owned by me"
# - Select the "DocumentBackup"
# - Select the Instance on which to run the command.
# - Click "Run"   
#
# I redirect all the logs to a monitorized file
exec > >(tee -a "/var/log/playbook.log") 2> >(tee -a "/var/log/playbook.log")

Playbook="{{PlaybookBackup}}"

[ ! -f "$Playbook" ] && echo "Invalid Playbook argument" && exit 1

ansible-playbook --extra-vars=@/root/playbooks/group_vars/stack.yaml --skip-tags "cleanup" "$Playbook"
