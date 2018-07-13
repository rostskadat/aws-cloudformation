#!/bin/bash
#
# FILE: add_user_to_gitlab.sh
#
# DESCRIPTION: This script will 
#
GitlabDNSName=$1
GitlabRootPassword=$2
SonarqubeAdminEmail=$3
TokenFile=$4

[ -z "${GitlabDNSName}" ] && echo "Invalid GitlabDNSName" && exit 1
[ -z "$GitlabRootPassword" ] && echo "Invalid GitlabRootPassword" && exit 1
[ -z "$SonarqubeAdminEmail" ] && echo "Invalid SonarqubeAdminEmail" && exit 1
[ -z "$TokenFile" ] && echo "Invalid TokenFile" && exit 1

GitlabDNSName=${GitlabDNSName,,}

echo "Obtaining a token..."
token=$(curl -s -F grant_type=password -F "username=root" -F "password=${GitlabRootPassword}" -X POST http://${GitlabDNSName}/oauth/token | jq -r '.access_token')
[ "$token" == "null" ] && echo "Failed to get Gitlab token" && exit 1

gitlabSonarqubePassword=$(echo -n "${SonarqubeAdminEmail}" | md5sum | cut -d ' ' -f 1)
SonarqubeAdminEmail=sonarqube@${SonarqubeAdminEmail##*@}
url="http://${GitlabDNSName}/api/v4"

echo "Checking if user 'sonarqube' exists..."
user_exists=$(curl -s -H "Authorization: Bearer $token" "$url/users" | jq '.[] | select (.username == "sonarqube" )')

if [ -z "$user_exists" ]; then
    echo "Creating sonarqube user in Gitlab @ $url (${SonarqubeAdminEmail})..."
    userId=$(curl -s --request POST -H "Authorization: Bearer $token" "$url/users" -F "email=${SonarqubeAdminEmail}" -F "password=$gitlabSonarqubePassword" -F "username=sonarqube" -F "name=Sonarqube User" -F "admin=true" -F "skip_confirmation=true" | jq '.id')
    gitlabSonarqubeToken=$(curl -s --request POST -H "Authorization: Bearer $token" "$url/users/$userId/impersonation_tokens" -F "name=SONARQUBE" -F "scopes[]=api" | jq -r '.token')
    [ "$gitlabSonarqubeToken" == "null" ] && echo "Failed to get Gitlab for Sonarqube user" && exit 1        
    echo -n "$gitlabSonarqubeToken" > $TokenFile
    chmog go-rwx $TokenFile
else
    echo "User 'sonarqube' exists in gitlab, not creating."
fi
