#!/bin/bash
logGroup="$1"
[ -z "$logGroup" ] && echo "Invalid logGroup" && exit 1

echo "Configuring Logstash..."
# Forcing to create init.d file
/usr/share/logstash/bin/system-install /etc/logstash/startup.options sysv
# Adding logs to awslog
cat >> /etc/awslogs/awslogs.conf <<EOF
[/var/log/logstash-stdout.log]
file = /var/log/logstash-stdout.log
log_stream_name = {instance_id}/var/log/logstash-stdout.log
log_group_name = ${logGroup}
[/var/log/logstash-stderr.log]
file = /var/log/logstash-stderr.log
log_stream_name = {instance_id}/var/log/logstash-stderr.log
log_group_name = ${logGroup}
[/var/log/logstash/grok_failures.txt]
file = /var/log/logstash/grok_failures.txt
log_stream_name = {instance_id}/var/log/logstash/grok_failures.txt
log_group_name = ${logGroup}
EOF
# Extracting GeoLite2-City DB
geodb=$(tar -tvf /tmp/GeoLite2-City.tar.gz | grep 'mmdb' | sed -E 's/.* ([^ ]+)$/\1/')
[ -d /usr/share/logstash/geolite ] || mkdir -p /usr/share/logstash/geolite
tar -xvzf /tmp/GeoLite2-City.tar.gz -C /usr/share/logstash/geolite $geodb
mv /usr/share/logstash/geolite/$geodb /usr/share/logstash/geolite/. 
