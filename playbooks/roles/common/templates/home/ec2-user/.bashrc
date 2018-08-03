[ -f /etc/bashrc ] && . /etc/bashrc
alias c=clear
alias l='ls -l'
alias vi=vim
alias sync_playbooks='sudo aws s3 sync s3://{{S3ConfigBucketName}}/playbooks/ /root/playbooks/ --exclude "group_vars/*.*"'
alias run_playbook_install='sudo /root/run_playbook_install.sh'
alias run_playbook_cleanup='sudo /root/run_playbook_cleanup.sh'
export AWS_DEFAULT_REGION={{Region}}
PS1='[\u@{{PromptName}} \W]\$ '