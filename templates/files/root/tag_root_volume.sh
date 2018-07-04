#!/bin/bash
#
# FILE: tag_root_volume.sh
#
# DESCRIPTION: This script will tag the EC2 instance root EBS Volume. This is taken from:
#   https://stackoverflow.com/questions/24026425/is-there-a-way-to-tag-a-root-volume-when-initializing-from-the-cloudformation-te
#   It will determine the volume_id attached to the current instance, extract the PLATFROM tag of that instance and
#   propagate the tag to the volume.
#
region="$1"
stack_name="$2"
[ -z "$region" ] && echo "Invalid region" && exit 1
[ -z "$stack_name" ] && echo "Invalid stack_name" && exit 1
echo "Tagging Root volume..."
instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
volume_id=$(aws --region $region ec2 describe-volumes --filters "Name=attachment.instance-id,Values=$instance_id" "Name=attachment.device,Values=/dev/xvda" --query "Volumes[0].VolumeId" --output text)
platform=$(aws --region $region ec2 describe-instances --instance-ids $instance_id --query "Reservations[0].Instances[0].Tags" --output table | grep PLATFORM | cut -d '|' -f 3 | sed -e 's/ //g')
aws --region $region ec2 create-tags --resources $volume_id --tag "Key=Name,Value=${stack_name}-VolumeRoot"
aws --region $region ec2 create-tags --resources $volume_id --tag "Key=PLATFORM,Value=$platform"