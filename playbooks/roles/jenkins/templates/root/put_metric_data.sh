#!/bin/bash

MetricName="$1"

[ -z "$MetricName" ] && echo "Invalid MetricName" && exit 1

case "$MetricName" in
    BuildActive) 
        aws --region {{Region}} cloudwatch put-metric-data --namespace {{StackName}} --metric-name BuildActive --value $(curl -s -m 60 -u 'admin:{{JenkinsAdminPassword}}' 'http://localhost:8080/computer/api/json' | jq -r '.busyExecutors') --unit Count ;;
    BuildQueue) 
        aws --region {{Region}} cloudwatch put-metric-data --namespace {{StackName}} --metric-name BuildQueue --value $(curl -s -m 60 -u 'admin:{{JenkinsAdminPassword}}' 'http://localhost:8080/jqs-monitoring/api/json' | jq '.buildQueue.numberOfJobs') --unit Count ;;
    *) echo "Invalid MetricName: Must be either BuildActive or BuildQueue" ;;
esac
