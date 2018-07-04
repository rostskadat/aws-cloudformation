#!/bin/bash
#
# FILE: create_db.sh
#
# DESCRIPTION: This script will 
#
endpointAddress="$1"
endpointPort="$2"
masterUsername="$3"
masterPassword="$4"
[ -z "$endpointAddress" ] && echo "Invalid endpointAddress" && exit 1
[ -z "$endpointPort" ] && echo "Invalid endpointPort" && exit 1
[ -z "$masterUsername" ] && echo "Invalid masterUsername" && exit 1
[ -z "$masterPassword" ] && echo "Invalid masterPassword" && exit 1

expect - <<EOF
spawn /usr/bin/createdb --host=$endpointAddress --port=$endpointPort --username=$masterUsername --encoding=UTF8 gitlabhq_production
expect "Password:"
send "$masterPassword\r"
expect eof
EOF
