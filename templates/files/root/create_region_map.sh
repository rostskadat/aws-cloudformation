#!/bin/bash
#
# FILE: create_region_map.sh
#
# DESCRIPTION: This script create the RegionMap used in the VPC stack. Just copy&paste the output to your stack
#
echo "  RegionMap: "
for region in $(aws --region eu-west-1 ec2 describe-regions --query 'Regions[*].{Name:RegionName}' --output text|sort -u); do
   latest_ami_name=$(aws --region $region ec2 describe-images --owners amazon --filters "Name=name,Values=amzn-ami-hvm-$(date +%Y)*-gp2" "Name=architecture,Values=x86_64" "Name=root-device-type,Values=ebs" --query 'Images[*].Name'|sort -r|head -1|tr -d '"'|xargs|sed -e 's/,//g')
   echo "    $region: "
   if [ ! -z "$latest_ami_name" ]; then
     echo -n "      ImageId: ";
     aws --region $region ec2 describe-images --owners amazon --filters "Name=name,Values=$latest_ami_name" --query 'Images[*].ImageId' --output text
   fi
   aws --region $region inspector list-rules-packages > /dev/null 2>&1 || continue;
   echo "      RulesPackageArns: ";
   while read arn; do 
       echo "        - '$arn'"; 
   done < <(aws --region $region inspector list-rules-packages 2> /dev/null | jq -r '.rulesPackageArns[]'); 
done
