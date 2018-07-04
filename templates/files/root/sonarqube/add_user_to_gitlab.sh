#!/bin/bash
#
# FILE: add_user_to_gitlab.sh
#
# DESCRIPTION: This script will 
#
GitlabDNSName=$1
GitlabRootPassword=$2
SonarqubeAdminEmail=$3

[ -z "${GitlabDNSName}" ] && echo "Invalid GitlabDNSName" && exit 1
[ -z "$GitlabRootPassword" ] && echo "Invalid GitlabRootPassword" && exit 1
[ -z "$SonarqubeAdminEmail" ] && echo "Invalid SonarqubeAdminEmail" && exit 1

GitlabDNSName=${GitlabDNSName,,}

echo "Obtaining a token..."
token=$(curl -s -F grant_type=password -F "username=root" -F "password=${GitlabRootPassword}" -X POST http://${GitlabDNSName}/oauth/token | jq '.access_token' | tr -d '"')
[ "$token" == "null" ] && echo "Failed to get Gitlab token" && exit 1

echo "Checking if user 'sonarqube' exists..."
user_exists=$(curl -s -H 'Authorization: Bearer $token' "$url/users" | jq '.[] | select (.username == "sonarqube" )')

if [ -z "$user_exists" ]; then
    gitlabSonarqubePassword=$(echo -n "${SonarqubeAdminEmail}" | md5sum | cut -d ' ' -f 1)
    url="http://${GitlabDNSName}/api/v4"
    SonarqubeAdminEmail=sonarqube.${SonarqubeAdminEmail}

    echo "Creating sonarqube user in Gitlab @ $url (${SonarqubeAdminEmail})..."
    userId=$(curl -s --request POST -H "Authorization: Bearer $token" "$url/users" -F "email=${SonarqubeAdminEmail}" -F "password=$gitlabSonarqubePassword" -F "username=sonarqube" -F "name=Sonarqube User" -F "admin=true" -F "skip_confirmation=true" | jq '.id')
    gitlabSonarqubeToken=$(curl -s --request POST -H "Authorization: Bearer $token" "$url/users/$userId/impersonation_tokens" -F "name=SONARQUBE" -F "scopes[]=api" | jq '.token' | tr -d '"')
    [ "$gitlabSonarqubeToken" == "null" ] && echo "Failed to get Gitlab for Sonarqube user" && exit 1        
    sed -ibckp -E "s/%gitlabSonarqubeToken%/$gitlabSonarqubeToken/" /opt/sonar/conf/sonar.properties
else
    echo "User 'sonarqube' exists in gitlab, not creating."
fi
