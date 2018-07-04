#!/bin/bash
#
# FILE: call_cli.sh
#
# DESCRIPTION: This script will
#
 
#exec > >(tee -a "/var/log/InstallApplication.log") 2> >(tee -a "/var/log/InstallApplication.log")
groovyFile=$1
optionalPassword="$2"
[ -z "$groovyFile" ] && echo "Invalid groovyFile" && exit 1
[ ! -f "$groovyFile" ] && echo "Invalid groovyFile: no such file" && exit 1
get_password()
{
  if [ -z "$optionalPassword" ]; then
    echo -n $(cat $initialPassword 2> /dev/null)
  else 
    echo -n $optionalPassword
  fi
}

initialPassword=/var/lib/jenkins/secrets/initialAdminPassword
cli=/var/cache/jenkins/war/WEB-INF/jenkins-cli.jar
url=http://localhost:8080
# --username admin --password "$(cat $initialPassword 2> /dev/null)"
java -jar $cli -s $url -auth "admin:$(get_password)" groovy = < <(cat $groovyFile)