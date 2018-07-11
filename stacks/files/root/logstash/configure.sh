#!/bin/bash
#
# FILE: configure.sh
#
# DESCRIPTION: This script will 
#
LogstashInputConfig="$1"
[ -z "${LogstashInputConfig}" ] && echo "Invalid LogstashInputConfig" && exit 1

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
