#!/bin/bash
#
# FILE: change_password.sh
#
# DESCRIPTION: This script will
#
endpointAddress="$1"
endpointPort="$2"
adminPassword="$3"
[ -z "$endpointAddress" ] && echo "Invalid endpointAddress" && exit 1
[ -z "$endpointPort" ] && echo "Invalid endpointPort" && exit 1
[ -z "$adminPassword" ] && echo "Invalid adminPassword" && exit 1

while : ; do 
    table_exists=$(mysql -h $endpointAddress -P $endpointPort --user=sonarqube --password=sonarqube --database=sonarqube --execute="SELECT * FROM sonarqube.users WHERE login = 'admin';" --batch --skip-column-names 2> /dev/null | wc -l);
    [ $table_exists -eq 0 ] || break;
    sleep 1
    echo -n .
done

mysql -h $endpointAddress -P $endpointPort --user=sonarqube --password=sonarqube --database=sonarqube  <<EOF
UPDATE users SET crypted_password=SHA1(CONCAT('--', salt, '--', '$adminPassword', '--')) WHERE id='1';
COMMIT;
 EOF