#!/bin/bash

ExitCode="$1"
Region="$2"
StackName="$3"
[ -z "$ExitCode" ] && echo "Invalid ExitCode" && exit 1
[ -z "$Region" ] && echo "Invalid Region" && exit 1
[ -z "$StackName" ] && echo "Invalid StackName" && exit 1

StackId=$(aws --region $Region cloudformation describe-stacks --stack-name $StackName --query "Stacks[0].StackId" --output text)
StackNameASG=$(aws --region $Region cloudformation describe-stacks --query "Stacks[?ParentId == '$StackId' && Tags[?Value == '$StackName-ASG' ]].StackName" --output text)
if [ ! -z "$StackNameASG" ]; then
	echo "Signaling $ExitCode to AutoScalingGroup (from Stack $StackNameASG)"
	/opt/aws/bin/cfn-signal -e 0 --region $Region --stack $StackNameASG --resource AutoScalingGroup	
else
	echo "No Nested Stack with Tag '$StackName-ASG' found. Bailing Out!"
fi
