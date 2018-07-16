#!/bin/bash

export HTTP_PROXY=http://as8400-s8400-de.allfunds.allfundsbank.corp:3128
export HTTPS_PROXY=http://as8400-s8400-de.allfunds.allfundsbank.corp:3128
export http_proxy=http://as8400-s8400-de.allfunds.allfundsbank.corp:3128
export https_proxy=http://as8400-s8400-de.allfunds.allfundsbank.corp:3128
S3_BUCKET_NAME=cloudformation-eu-west-1-791682668801

/usr/local/bin/aws s3 sync stacks s3://$S3_BUCKET_NAME/stacks
/usr/local/bin/aws s3 sync playbooks s3://$S3_BUCKET_NAME/playbooks
echo "Sync OK"

