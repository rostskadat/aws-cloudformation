#!/bin/bash -ex
instanceId=$(curl -s -m 60 http://169.254.169.254/latest/meta-data/instance-id)
masterInstanceId=$(aws --region {{Region}} autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${MasterASG} --query 'AutoScalingGroups[0].Instances[0].InstanceId' --output text)
masterIP=$(aws --region{{Region}} ec2 describe-instances --instance-ids $masterInstanceId --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
secret=$(curl -s -m 60 -u 'admin:{{JenkinsAdminPassword}}' http://$masterIP:8080/computer/$instanceId/slave-agent.jnlp | xmllint --xpath '//argument[1]/text()' -)
java -classpath remoting.jar hudson.remoting.jnlp.Main $secret $instanceId -url http://$masterIP:8080/ -headless
