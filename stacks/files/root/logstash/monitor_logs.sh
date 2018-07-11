#!/bin/bash
# Adding logs to awslog

LogGroup="$1"

[ -z "${LogGroup}" ] && echo "Invalid LogGroup" && exit 1

/root/monitor_log.sh "${LogGroup}" /var/log/logstash-stdout.log
/root/monitor_log.sh "${LogGroup}" /var/log/logstash-stderr.log
/root/monitor_log.sh "${LogGroup}" /var/log/logstash/grok_failures.txt
