#!/bin/bash
# Adding logs to awslog

LogGroup="$1"

[ -z "${LogGroup}" ] && echo "Invalid LogGroup" && exit 1

/root/monitor_log.sh "${LogGroup}" /opt/sonar/logs/access.log 
/root/monitor_log.sh "${LogGroup}" /opt/sonar/logs/ce.log 
/root/monitor_log.sh "${LogGroup}" /opt/sonar/logs/es.log 
/root/monitor_log.sh "${LogGroup}" /opt/sonar/logs/sonar.log 
/root/monitor_log.sh "${LogGroup}" /opt/sonar/logs/web.log
