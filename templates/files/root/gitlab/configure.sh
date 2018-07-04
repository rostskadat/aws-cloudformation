#!/bin/bash
#
# FILE: configure.sh
#
# DESCRIPTION: This script will 
#
email=$1
password=$2
[ -z "$email" ] && echo "Invalid email" && exit 1
[ -z "$password" ] && echo "Invalid password" && exit 1
GITLAB_ROOT_EMAIL="$email" GITLAB_ROOT_PASSWORD="$password" gitlab-ctl reconfigure