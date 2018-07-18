[ -f /etc/bashrc ] && . /etc/bashrc
alias c=clear
alias l='ls -l'
alias vi=vim
alias sync_playbooks='sudo aws s3 sync s3://{{S3ConfigBucketName}}/playbooks/ /root/playbooks/ --exclude "group_vars/*.*"'
alias run_playbook='sudo ansible-playbook --extra-vars=@/root/playbooks/group_vars/stack.yaml --skip-tags "cleanup"'
export AWS_DEFAULT_REGION={{Region}}
PS1='[\u@{{StackName}} \W]\$ '