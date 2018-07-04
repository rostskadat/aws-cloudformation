#!/bin/bash
#
# FILE: wait.sh
#
# DESCRIPTION: This script will
#
optionalPassword="$1"
initialPassword=/var/lib/jenkins/secrets/initialAdminPassword
cli=/var/cache/jenkins/war/WEB-INF/jenkins-cli.jar
url=http://localhost:8080
# make sure that I re-read the initial password each time...
get_password()
{
  if [ -z "$optionalPassword" ]; then
    echo -n $(cat $initialPassword 2> /dev/null)
  else 
    echo -n $optionalPassword
  fi
}
echo -n "Waiting for Jenkins..."
i=0
while [ ! -f $initialPassword ] || [ ! -f $cli ]; do 
  echo -n .; sleep 1
  i=$((i+1))
  [ $i -gt 120 ] && echo "Jenkins failed to start in 120 seconds. Bailing out!" && exit 1
done
i=0
echo " OK"
echo -n "Waiting for Jenkins API..."
until $(curl -s --max-time 60 -o /dev/null --head --fail --user "admin:$(get_password)" $url/cli/); do
  echo -n .; sleep 1
  i=$((i+1))
  [ $i -gt 120 ] && echo "Jenkins failed to start in 120 seconds. Bailing out!" && exit 1
done
echo " OK"