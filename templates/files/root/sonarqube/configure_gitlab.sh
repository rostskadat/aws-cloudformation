#!/bin/bash
#
# FILE: configure_gitlab.sh
#
# DESCRIPTION: This script will 
#

gitlabDNSName=$1
gitlabRootPassword=$2
sonarqubeAdminEmail=$3

[ -z "$gitlabDNSName" ] && echo "Invalid gitlabDNSName" && exit 1
[ -z "$gitlabRootPassword" ] && echo "Invalid gitlabRootPassword" && exit 1
[ -z "$sonarqubeAdminEmail" ] && echo "Invalid sonarqubeAdminEmail" && exit 1

gitlabDNSName=${gitlabDNSName,,}
# Obtain a token
token=$(curl -s -F grant_type=password -F "username=root" -F "password=$gitlabRootPassword" -X POST http://$gitlabDNSName/oauth/token | jq '.access_token' | tr -d '"')
[ "$token" == "null" ] && echo "Failed to get Gitlab token" && exit 1
# Let's create a user
gitlabSonarqubePassword=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
url="http://$gitlabDNSName/api/v4"
sonarqubeAdminEmail=sonarqube@${sonarqubeAdminEmail##*@}

echo "Creating sonarqube user in Gitlab @ $url ($sonarqubeAdminEmail)"

userId=$(curl -s --request POST -H "Authorization: Bearer $token" "$url/users" -F "email=$sonarqubeAdminEmail" -F "password=$gitlabSonarqubePassword" -F "username=sonarqube" -F "name=Sonarqube User" -F "admin=true" -F "skip_confirmation=true" | jq '.id')
gitlabSonarqubeToken=$(curl -s --request POST -H "Authorization: Bearer $token" "$url/users/$userId/impersonation_tokens" -F "name=SONARQUBE" -F "scopes[]=api" | jq '.token' | tr -d '"')
[ "$gitlabSonarqubeToken" == "null" ] && echo "Failed to get Gitlab for Sonarqube user" && exit 1        
sed -ibckp -E "s/%gitlabSonarqubeToken%/$gitlabSonarqubeToken/" /opt/sonar/conf/sonar.properties