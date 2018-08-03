#!/bin/bash
#
# FILE: efs-restore.sh
#
# DESCRIPTION: This script restore a specific efs backup
#
# Modified from https://github.com/aws-samples/data-pipeline-samples/tree/master/samples/EFSBackup
#
#------------------------------------------------------------------------------
exec > >(tee -a "/var/log/efs-restore.log") 2> >(tee -a "/var/log/efs-restore.log")


# Input arguments
# Input arguments
SourceEFS="{{FileSystem}}"
BackupEFS="$1"
Interval="$2"
Retain="$3"

echo "Playing restaure playbook..."

source=$1
destination=$2
interval=$3
backupNum=$4
efsid=$5

# Prepare system for rsync
efs_init $source /backup $destination /mnt/backups

if [ ! test -d /mnt/backups/$efsid/$interval.$backupNum/ ]; then
    echo "EFS Backup $efsid/$interval.$backupNum does not exist!"
    exit 1
fi

rsync -ah --stats --delete --numeric-ids --log-file=/tmp/efs-restore.log /mnt/backups/$efsid/$interval.$backupNum/ /backup/
rsyncStatus=$?
cp /tmp/efs-restore.log /mnt/backups/efsbackup-logs/$efsid-$interval.$backupNum-restore-`date +%Y%m%d-%H%M`.log
exit $rsyncStatus
