#!/bin/bash

S3_BUCKET_NAME=cloudformation-eu-west-1-791682668801
AWS=$(([ -f /usr/local/bin/aws ] && echo -n /usr/local/bin/aws) || echo -n $(which aws))

$AWS s3 sync stacks/ s3://$S3_BUCKET_NAME/stacks/

$AWS cloudformation validate-template \
    --template-url https://s3.amazonaws.com/$S3_BUCKET_NAME/stacks/01-vpc.yaml

#$AWS cloudformation validate-template \
#    --template-url https://s3.amazonaws.com/$S3_BUCKET_NAME/stacks/02-bastion.yaml

#$AWS cloudformation validate-template \
#    --template-url https://s3.amazonaws.com/$S3_BUCKET_NAME/stacks/analytics/logstash.yaml
