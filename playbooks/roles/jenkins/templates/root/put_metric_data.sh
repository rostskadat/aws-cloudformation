#!/bin/bash

MetricName="$1"

[ -z "$MetricName" ] && echo "Invalid MetricName" && exit 1

credentials="admin:{{JenkinsAdminPassword}}"

case "$MetricName" in
    BuildActive)
        value=$(curl -s -m 60 -u "$credentials" 'http://localhost:8080/computer/api/json' | jq -r '.busyExecutors') ;;
    BuildQueue)
        value=$(curl -s -m 60 -u "$credentials" 'http://localhost:8080/jqs-monitoring/api/json' | jq '.buildQueue.numberOfJobs') ;;
    *) echo "Invalid MetricName: Must be either BuildActive or BuildQueue" && exit 1;;
esac
echo "Add metric $MetricName: $value"
aws --region "{{Region}}" cloudwatch put-metric-data --namespace "{{StackName}}" --metric-name $MetricName --unit Count --value $value
