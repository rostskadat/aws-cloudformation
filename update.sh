#!/bin/bash

export HTTP_PROXY=http://as8400-s8400-de.allfunds.allfundsbank.corp:3128
export HTTPS_PROXY=http://as8400-s8400-de.allfunds.allfundsbank.corp:3128
export http_proxy=http://as8400-s8400-de.allfunds.allfundsbank.corp:3128
export https_proxy=http://as8400-s8400-de.allfunds.allfundsbank.corp:3128
S3_BUCKET_NAME=cloudformation-eu-west-1-791682668801

AWS=/usr/local/bin/aws

$AWS s3 sync stacks/ s3://$S3_BUCKET_NAME/stacks/


$AWS cloudformation update-stack \
    --stack-name BUILD \
    --template-url https://s3.amazonaws.com/$S3_BUCKET_NAME/stacks/01-vpc.yaml
    --capabilities CAPABILITY_IAM \
    --parameters \
        "ParameterKey=S3ConfigBucketName,UsePreviousValue=true" \
        "ParameterKey=AWSInspectorDLQEmail,UsePreviousValue=true" \
        "ParameterKey=UseVPCFlowLog,UsePreviousValue=true" \
        "ParameterKey=HealthNotificationEmail,UsePreviousValue=true"

#$AWS cloudformation update-stack \
#    --stack-name BUILD-BASTION \
#    --template-url https://s3.amazonaws.com/$S3_BUCKET_NAME/stacks/02-bastion.yaml \
#    --capabilities CAPABILITY_IAM \
#    --parameters \

#$AWS cloudformation update-stack \
#    --stack-name BUILD-LOGSTASH \
#    --template-url https://s3.amazonaws.com/$S3_BUCKET_NAME/stacks/analytics/logstash.yaml \
#    --capabilities CAPABILITY_IAM \
#    --parameters \
#        "ParameterKey=ParentVpcStack,UsePreviousValue=true" \
#        "ParameterKey=KeyName,UsePreviousValue=true" \
#        "ParameterKey=InstanceType,UsePreviousValue=true" \
#        "ParameterKey=ElasticSearchAdminEmail,UsePreviousValue=true" \
#        "ParameterKey=ElasticSearchVolumeSize,UsePreviousValue=true" \
#        "ParameterKey=ElasticSearchInstanceType,UsePreviousValue=true" \
#        "ParameterKey=S3LogsBucketName,UsePreviousValue=true" \
#        "ParameterKey=S3LogsIncludeFilters,UsePreviousValue=true"
