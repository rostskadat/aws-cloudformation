#!/bin/bash

ROOT_DIR=$(dirname "${BASH_SOURCE[0]}")

sonarqubeDNSName="$1"
sonarqubeAdminPassword="$2"
jenkinsAdminEmail="$3"
[ -z "$sonarqubeDNSName" ] && echo "Invalid sonarqubeDNSName" && exit 1
[ -z "$sonarqubeAdminPassword" ] && echo "Invalid sonarqubeAdminPassword" && exit 1
[ -z "$jenkinsAdminEmail" ] && echo "Invalid jenkinsAdminEmail" && exit 1
# First create a user 
sonarqubeDNSName=${sonarqubeDNSName,,}
apiUrl="http://$sonarqubeDNSName/api"
jenkinsPassword=$(echo -n "$jenkinsAdminEmail" | md5sum | cut -d ' ' -f 1)
sonarqubeUserEmail=jenkins@${jenkinsAdminEmail##*@}

exists=$(curl -s -u "admin:$sonarqubeAdminPassword" -X GET $apiUrl/users/search | jq -r '.users[].login' | grep -c jenkins)
if [ $exists -eq 0 ]; then
  curl -s -u "admin:$sonarqubeAdminPassword" -X POST $apiUrl/users/create \
    -F "local=true" \
    -F "login=jenkins" \
    -F "name=Jenkins User" \
    -F "password=$jenkinsPassword" \
    -F "email=$sonarqubeUserEmail"
else
  echo "Jenkins User exists in Sonarqube. Not creating."
fi

exists=$(curl -s -u "admin:$sonarqubeAdminPassword" -X GET $apiUrl/user_tokens/search?login=jenkins | jq -r '.userTokens[].name' | grep -c JENKINS_TOKEN)
if [ $exists -ne 0 ]; then
  echo "JENKINS_TOKEN exists in Sonarqube. Revoking."
  curl -s -u "admin:$sonarqubeAdminPassword" -X POST $apiUrl/user_tokens/revoke \
    -F "login=jenkins" \
    -F "name=JENKINS_TOKEN"
fi
sonarqubeToken=$(curl -s -u "admin:$sonarqubeAdminPassword" -X POST $apiUrl/user_tokens/generate -F "login=jenkins" -F "name=JENKINS_TOKEN" | jq -r ".token")

sed -i -E "s/%sonarqubeToken%/$sonarqubeToken/" $ROOT_DIR/configure_sonarqube.groovy
$ROOT_DIR/call_cli.sh $ROOT_DIR/configure_sonarqube.groovy