#!/bin/bash
s3ImportBucketName="$1"
[ -z "$s3ImportBucketName" ] && echo "Invalid s3ImportBucketName" && exit 1

DST_DIR=/var/log/imported
[ -d $DST_DIR ] || mkdir -p $DST_DIR
chmod go+rx $DST_DIR
aws s3 sync s3://$s3ImportBucketName/ $DST_DIR/ --exclude "*" --include "*SSL_access_$(date +"%Y-%m-%d")-00_00_00.log"
aws s3 sync s3://$s3ImportBucketName/ $DST_DIR/ --exclude "*" --include "*ArcQueriesTrace.log"
aws s3 sync s3://$s3ImportBucketName/ $DST_DIR/ --exclude "*" --include "*api-backend.log"
find $DST_DIR/ -name SSL_access_$(date --date="-1 day" +"%Y-%m-%d")-00_00_00.log -exec rm {} \;