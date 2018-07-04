#!/bin/bash
#
# FILE: create_fs.sh
#
# DESCRIPTION: This script will mount the EFS file system used by the application. 
#
fileSystem="$1"
[ -z "$fileSystem" ] && echo "Invalid fileSystem" && exit 1

MNT=/mnt/application
[ -d $MNT ] || mkdir $MNT
mount -t efs -o tls ${fileSystem}:/ $MNT
[ -d $MNT/data ] || mkdir -p $MNT/data
[ -d $MNT/data ] && echo "File system OK"
