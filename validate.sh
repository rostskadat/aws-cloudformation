#!/bin/bash

export HTTP_PROXY=http://as8400-s8400-de.allfunds.allfundsbank.corp:3128
export HTTPS_PROXY=http://as8400-s8400-de.allfunds.allfundsbank.corp:3128
export http_proxy=http://as8400-s8400-de.allfunds.allfundsbank.corp:3128
export https_proxy=http://as8400-s8400-de.allfunds.allfundsbank.corp:3128
S3_BUCKET_NAME=cloudformation-eu-west-1-791682668801

AWS=/usr/local/bin/aws

$AWS s3 sync stacks/ s3://$S3_BUCKET_NAME/stacks/

$AWS cloudformation validate-template \
    --template-url https://s3.amazonaws.com/$S3_BUCKET_NAME/stacks/01-vpc.yaml

#$AWS cloudformation validate-template \
#    --template-url https://s3.amazonaws.com/$S3_BUCKET_NAME/stacks/02-bastion.yaml

#$AWS cloudformation validate-template \
#    --template-url https://s3.amazonaws.com/$S3_BUCKET_NAME/stacks/analytics/logstash.yaml
