#!/bin/bash
#
# FILE: apply_settings.sh
#
# DESCRIPTION: This script will apply the configuration found in the associated YAML file
#
adminPassword=$1
[ -z "$adminPassword" ] && echo "Invalid adminPassword" && exit 1

URL="http://localhost:8081/artifactory/api/system/configuration"
HEADER="Content-Type: application/yaml"
curl --silent \
    --request PATCH \
    --header "$HEADER" \
    --user "admin:$adminPassword" \
    --upload-file /root/artifactory/settings.yaml \ 
    "$URL"