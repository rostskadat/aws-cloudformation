#!/bin/bash
# Adding logs to awslog

LogGroup="$1"

[ -z "${LogGroup}" ] && echo "Invalid LogGroup" && exit 1


cat >> /etc/awslogs/awslogs.conf <<EOF
[/var/log/jenkins/jenkins.log]
file = /var/log/jenkins/jenkins.log
log_stream_name = {instance_id}/var/log/jenkins/jenkins.log
log_group_name = ${LogGroup}
EOF

service awslogs restart