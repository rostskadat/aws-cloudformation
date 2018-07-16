#!/bin/bash

S3_BUCKET_NAME=cloudformation-eu-west-1-791682668801
AWS=$(([ -f /usr/local/bin/aws ] && echo -n /usr/local/bin/aws) || echo -n $(which aws))

$AWS s3 sync stacks s3://$S3_BUCKET_NAME/stacks
$AWS s3 sync playbooks s3://$S3_BUCKET_NAME/playbooks
echo "Sync OK"

