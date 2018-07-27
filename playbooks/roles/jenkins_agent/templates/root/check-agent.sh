#!/bin/bash -ex
masterInstanceId=$(aws --region {{Region}} autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${MasterASG} --query 'AutoScalingGroups[0].Instances[0].InstanceId' --output text)
masterIP=$(aws --region {{Region}} ec2 describe-instances --instance-ids $masterInstanceId --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
java -jar jenkins-cli.jar -s http://$masterIP:8080 -auth 'admin:${MasterAdminPassword}' get-node $(curl -s -m 60 http://169.254.169.254/latest/meta-data/instance-id)
