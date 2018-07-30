#!/bin/bash

ExitCode="$1"
Region="$2"
StackName="$3"
StackTag="$4"
AutoScalingGroup="$5"
[ -z "$ExitCode" ] && echo "Invalid ExitCode" && exit 1
[ -z "$Region" ] && echo "Invalid Region" && exit 1
[ -z "$StackName" ] && echo "Invalid StackName" && exit 1
[ -z "$StackTag" ] && echo "Invalid StackTag" && exit 1
[ -z "$AutoScalingGroup" ] && echo "Invalid AutoScalingGroup" && exit 1

StackId=$(aws --region $Region cloudformation describe-stacks --stack-name $StackName --query "Stacks[0].StackId" --output text)
StackNameASG=$(aws --region $Region cloudformation describe-stacks --query "Stacks[?ParentId == '$StackId' && Tags[?Value == '$StackName-$StackTag' ]].StackName" --output text)
if [ ! -z "$StackNameASG" ]; then
	echo "Signaling $ExitCode to $AutoScalingGroup (from Stack $StackNameASG)"
	/opt/aws/bin/cfn-signal -e 0 --region "$Region" --stack "$StackNameASG" --resource "$AutoScalingGroup"
else
	echo "No Nested Stack with Tag '$StackName-ASG' found. Bailing Out!"
fi
