#!/bin/bash
# Modified from https://github.com/aws-samples/data-pipeline-samples/tree/master/samples/EFSBackup
BASE_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. $BASE_DIR/efs-lib.sh
exec > >(tee -a "/var/log/efs-backup.log") 2> >(tee -a "/var/log/efs-backup.log")


# Input arguments
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
