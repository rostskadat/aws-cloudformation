#!/bin/bash
#
# FILE: configure.sh
#
# DESCRIPTION: This script will 
#
LogGroup="$1"
LogstashInputConfig="$2"
[ -z "${LogGroup}" ] && echo "Invalid LogGroup" && exit 1
[ -z "${LogstashInputConfig}" ] && echo "Invalid LogstashInputConfig" && exit 1

# Adding logs to awslog
cat >> /etc/awslogs/awslogs.conf <<EOF
[/var/log/logstash-stdout.log]
file = /var/log/logstash-stdout.log
log_stream_name = {instance_id}/var/log/logstash-stdout.log
log_group_name = ${LogGroup}
[/var/log/logstash-stderr.log]
file = /var/log/logstash-stderr.log
log_stream_name = {instance_id}/var/log/logstash-stderr.log
log_group_name = ${LogGroup}
[/var/log/logstash/grok_failures.txt]
file = /var/log/logstash/grok_failures.txt
log_stream_name = {instance_id}/var/log/logstash/grok_failures.txt
log_group_name = ${LogGroup}
EOF

echo "Configuring Logstash init script..."
/usr/share/logstash/bin/system-install /etc/logstash/startup.options sysv

echo "Extracting GeoLite2-City DB..."
geodb=$(tar -tvf /tmp/GeoLite2-City.tar.gz | grep 'mmdb' | sed -E 's/.* ([^ ]+)$/\1/')
[ -d /usr/share/logstash/geolite ] || mkdir -p /usr/share/logstash/geolite
tar -xvzf /tmp/GeoLite2-City.tar.gz -C /usr/share/logstash/geolite $geodb
mv /usr/share/logstash/geolite/$geodb /usr/share/logstash/geolite/. 

echo "Configuring input..."
aws s3 cp ${LogstashInputConfig} /etc/logstash/conf.d/01-input.conf

echo "Configuring IPv4..."
echo "-Djava.net.preferIPv4Stack=true" >> /etc/logstash/jvm.options
sed -ibckp -E "s/.*http.host.*/http.host: '0.0.0.0'/" /etc/logstash/logstash.yml
