#!/bin/bash
#
# FILE: s3_sync_logs.sh
#
# DESCRIPTION: This script will 
#
S3LogsIncludeFilters="{{S3LogsIncludeFilters}}"
[ -z "${S3LogsIncludeFilters}" ] && echo "Invalid S3LogsIncludeFilters" && exit 1

DST_DIR=/var/log/imported
[ -d $DST_DIR ] || mkdir -p $DST_DIR
chmod go+rx $DST_DIR

IFS=','
for include_filter in $(echo -n "${S3LogsIncludeFilters}"); do
    aws s3 sync s3://${S3LogsBucketName}/ $DST_DIR/ --exclude "*" --include "${S3LogsIncludeFilters}"
done
find $DST_DIR/ -name SSL_access_$(date --date="-1 day" +"%Y-%m-%d")-00_00_00.log -exec rm {} \;


