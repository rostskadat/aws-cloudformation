#!/bin/bash
#
# FILE: create_db.sh
#
# DESCRIPTION: This script creates the Database.
#
# BEWARE: IT WILL ANY EXISTING DB 
#
endpointAddress=$1
endpointPort=$2
masterUsername=$3
masterPassword=$4
[ -z "$endpointAddress" ] && echo "Invalid endpointAddress" && exit 1
[ -z "$endpointPort" ] && echo "Invalid endpointPort" && exit 1
[ -z "$masterUsername" ] && echo "Invalid masterUsername" && exit 1
[ -z "$masterPassword" ] && echo "Invalid masterPassword" && exit 1

mysql -h $endpointAddress -P $endpointPort --user=$masterUsername --password=$masterPassword <<EOF
DROP DATABASE IF EXISTS sonarqube;
CREATE DATABASE sonarqube CHARACTER SET utf8 COLLATE utf8_bin;
GRANT ALL on sonarqube.* TO 'sonarqube'@'%' IDENTIFIED BY 'sonarqube';
FLUSH PRIVILEGES;
EOF
