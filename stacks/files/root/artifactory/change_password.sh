#!/bin/bash
#
# FILE: change_password.sh
#
# DESCRIPTION: This script will change the default Artifactory Admin password 
#
oldPassword="$1"
newPassword="$2"
[ -z "$oldPassword" ] && echo "Invalid old password" && exit 1
[ -z "$newPassword" ] && echo "Invalid new password" && exit 1

API_URL="http://localhost:8081/artifactory/api"
header="Content-type: application/json"
data='{ "userName":"admin", "oldPassword":"'"$oldPassword"'", "newPassword1":"'"$newPassword"'", "newPassword2":"'"$newPassword"'"}'
url="$API_URL/security/users/authorization/changePassword"
echo -n "Changing default admin password"
while (true); do
    result=$(curl -s --user "admin:$oldPassword" -H "$header" -d "$data" -X POST "$url")
    [ $(echo -n "$result" | grep -c "Password has been successfully changed") -gt 0 ] && break
    echo -n "."
    sleep 2
done