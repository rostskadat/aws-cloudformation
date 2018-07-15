#!/bin/bash

Region={{ Region }}
UserPoolId="{{ UserPoolId }}"
IdentityPoolId="{{ IdentityPoolId }}"
ESDomainName="{{ ESDomainName }}"
RoleArn="{{ RoleArn }}"

#UserPoolId="eu-west-1_CaQD6NePH"
#IdentityPoolId="eu-west-1:6d69ae48-31a6-4381-9a13-c49cac1b949b"
#ESDomainName="build-l-domain-1wv2igd1j37eu"
#RoleArn="arn:aws:iam::791682668801:role/service-role/CognitoAccessForAmazonES"

echo "Checking if ESDomain $ESDomainName is already configured..."
Enabled=$(aws --region $region es describe-elasticsearch-domain --domain-name $ESDomainName | jq '.DomainStatus.CognitoOptions.Enabled')
if [ "$Enabled" == "true" ]; then
	echo "Cognito already enabled for domain $DomainName. Bailing out!"
	exit 0
else
	echo "ESDomain $ESDomainName is not configured to use Cognito"
fi

echo "Checking if UserPool $UserPoolId has a Domain..."
Domain=$(aws --region $region cognito-idp describe-user-pool --user-pool-id $UserPoolId | jq -r '.UserPool.Domain')
if [ -z "$Domain" ]; then
	echo "UserPool $UserPoolId has no Domain associated"
else
	echo "UserPool $UserPoolId is associated with Domain $Domain..."
fi

aws es update-elasticsearch-domain-config --domain-name $ESDomainName \
	--cognito-options "Enabled=true,UserPoolId=$UserPoolId,IdentityPoolId=$IdentityPoolId,RoleArn=$RoleArn"
