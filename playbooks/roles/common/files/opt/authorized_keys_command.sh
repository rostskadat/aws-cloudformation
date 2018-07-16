#!/bin/bash -e
# 
# FILE: authorized_keys_command.sh
#
# DESCRIPTION: Will output all the ssh public key of the given user. Used as an
#   AuthorizedKeysCommand in the /etc/ssh/sshd_config
#
# FROM: https://github.com/widdix/aws-cf-templates/blob/master/jenkins/jenkins2-ha.yaml
#
if [ -z "$1" ]; then
    exit 1
fi
UnsaveUserName="$1"
UnsaveUserName=${UnsaveUserName//".plus."/"+"}
UnsaveUserName=${UnsaveUserName//".equal."/"="}
UnsaveUserName=${UnsaveUserName//".comma."/","}
UnsaveUserName=${UnsaveUserName//".at."/"@"}
aws iam list-ssh-public-keys --user-name "$UnsaveUserName" --query "SSHPublicKeys[?Status == 'Active'].[SSHPublicKeyId]" --output text | while read -r KeyId; do
    aws iam get-ssh-public-key --user-name "$UnsaveUserName" --ssh-public-key-id "$KeyId" --encoding SSH --query "SSHPublicKey.SSHPublicKeyBody" --output text
done
