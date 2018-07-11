#!/bin/bash
# Adding logs to awslog

LogGroup="$1"
LogFile="$2"

[ -z "${LogGroup}" ] && echo "Invalid LogGroup" && exit 1
[ -z "${LogFile}" ] && echo "Invalid LogFile" && exit 1

cat >> /etc/awslogs/awslogs.conf <<EOF
[${LogFile}]
file = ${LogFile}
log_stream_name = {instance_id}${LogFile}
log_group_name = ${LogGroup}
EOF

service awslogs restart