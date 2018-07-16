#!/bin/bash -e
# 
# FILE: import_users.sh
#
# DESCRIPTION: Will output all the ssh public key of the given user. Used as an
#   AuthorizedKeysCommand in the /etc/ssh/sshd_config
#
# FROM: https://github.com/widdix/aws-cf-templates/blob/master/jenkins/jenkins2-ha.yaml
#

aws iam list-users --query "Users[].[UserName]" --output text | while read User; do
    SaveUserName="$User"
    SaveUserName=${SaveUserName//"+"/".plus."}
    SaveUserName=${SaveUserName//"="/".equal."}
    SaveUserName=${SaveUserName//","/".comma."}
    SaveUserName=${SaveUserName//"@"/".at."}
    if [ "${#SaveUserName}" -le "32" ]; then
        if ! id -u "$SaveUserName" >/dev/null 2>&1; then
            #sudo will read each file in /etc/sudoers.d, skipping file names that end in '~' or contain a '.' character to avoid causing problems with package manager or editor temporary/backup files.
            SaveUserFileName=$(echo "$SaveUserName" | tr "." " ")
            /usr/sbin/useradd "$SaveUserName"
            echo "$SaveUserName ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$SaveUserFileName"
        fi
    else
        echo "Can not import IAM user ${SaveUserName}. User name is longer than 32 characters."
    fi
done