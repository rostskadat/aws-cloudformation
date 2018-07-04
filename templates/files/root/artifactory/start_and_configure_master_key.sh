#!/bin/bash
#
# FILE: start_and_configure_master_key.sh
#
# DESCRIPTION: This script will 
#
MASTER_KEY_TARGET=/etc/opt/jfrog/artifactory/security/master.key
MASTER_KEY_BACKUP=/mnt/application/data/master.key
if [ -f '/mnt/application/.application_configured' ]; then
    echo "This is not the first install. Restoring $MASTER_KEY_TARGET from $MASTER_KEY_BACKUP"
    [ -d $(dirname $MASTER_KEY_TARGET) ] ||  mkdir -p $(dirname $MASTER_KEY_TARGET)
    cp $MASTER_KEY_BACKUP $MASTER_KEY_TARGET
    chown -R artifactory.artifactory /etc/opt/jfrog/artifactory
    service artifactory start
else
    service artifactory start
    echo -n "Waiting for master.key to be available"
    while [ ! -f $MASTER_KEY_TARGET ]; do 
        sleep 1 
        echo -n "."
    done
    cp $MASTER_KEY_TARGET $MASTER_KEY_BACKUP
fi
