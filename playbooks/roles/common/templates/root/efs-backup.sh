#!/bin/bash
#
# FILE: efs-backup.sh
#
# DESCRIPTION: This script allows the backup of the instance EFS file system.
#   It is deployed on each instance and called from a SSM document created by 
#   the calling stack.
#
# SYNOPSIS:
# Example would be to run this script as follows:
# Every 6 hours; retain last 4 backups
# efs-backup.sh efs-12345 efs-54321 hourly 4
# Once a day; retain last 31 days
# efs-backup.sh efs-12345 efs-54321 daily 31
# Once a week; retain 4 weeks of backup
# efs-backup.sh efs-12345 efs-54321 weekly 7
# Once a month; retain 3 months of backups
# efs-backup.sh efs-12345 efs-54321 monthly 3
#
# Snapshots will look like:
# $dst/$SourceEFS/hourly.0-3; daily.0-30; weekly.0-3; monthly.0-2
#
# Modified from https://github.com/aws-samples/data-pipeline-samples/tree/master/samples/EFSBackup
#
#------------------------------------------------------------------------------

exec > >(tee -a "/var/log/efs-backup.log") 2> >(tee -a "/var/log/efs-backup.log")

# Input arguments
SourceEFS="{{FileSystem}}"
BackupEFS="$1"
Interval="$2"
Retain="$3"

[ -z "$SourceEFS" ] && echo "Invalid SourceEFS" && exit 1
[ -z "$BackupEFS" ] && echo "Invalid BackupEFS" && exit 1
[ -z "$Interval" ] && echo "Invalid Interval" && exit 1
[ -z "$Retain" ] && echo "Invalid Retain" && exit 1

#
# In all the different playbooks the application EFS is mounted on /mnt/application
#
SourceDir=/mnt/application
BackupDir=/mnt/backups

#==============================================================================
#
# MAIN PROGRAM SECTION.
# 
#==============================================================================
[ ! -d "$SourceDir" ] && echo "Application does not seem to be mounted on $SourceDir" && exit 1

echo "Backing up EFS for stack {{StackName}}. Please, stand by..."

echo "Playing backup playbook..."
#aws autoscaling suspend-processes --auto-scaling-group-name my-asg
echo "Stoping services..."
#aws autoscaling suspend-processes --auto-scaling-group-name my-asg

yum -y install amazon-efs-utils
#mkdir -p $SourceDir
mkdir -p $BackupDir
#mount -t efs -o tls $SourceEFS $SourceDir
mount -t efs -o tls $BackupEFS $BackupDir

# we need to decrement Retain because we start counting with 0 and we need to remove the oldest backup
let "Retain=$Retain-1"
if test -d $BackupDir/$SourceEFS/$Interval.$Retain; then
    rm -rf $BackupDir/$SourceEFS/$Interval.$Retain
fi

# Rotate all previous backups (except the first one), up one level
for x in $(seq $Retain -1 2); do
    if test -d $BackupDir/$SourceEFS/$Interval.$[$x-1]; then
        mv $BackupDir/$SourceEFS/$Interval.$[$x-1] $BackupDir/$SourceEFS/$Interval.$x
    fi
done

# Copy first backup with hard links, then replace first backup with new backup
if test -d $BackupDir/$SourceEFS/$Interval.0 ; then
    cp -al $BackupDir/$SourceEFS/$Interval.0 $BackupDir/$SourceEFS/$Interval.1
fi
if [ ! -d $BackupDir/$SourceEFS ]; then
    mkdir -p $BackupDir/$SourceEFS
    chmod 700 $BackupDir/$SourceEFS
fi
if [ ! -d $BackupDir/efsbackup-logs ]; then
    mkdir -p $BackupDir/efsbackup-logs
    chmod 700 $BackupDir/efsbackup-logs
fi
rsync -ah --stats --delete --numeric-ids --log-file=/var/log/efs-backup.log $SourceDir/ $BackupDir/$SourceEFS/$Interval.0/
rsyncStatus=$?
cp /var/log/efs-backup.log $BackupDir/efsbackup-logs/$SourceEFS-$(date +%Y%m%d-%H%M).log
touch $BackupDir/$SourceEFS/$Interval.0/
exit $rsyncStatus
