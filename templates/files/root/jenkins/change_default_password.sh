#!/bin/bash
password="$1"
[ -z "$password" ] && echo "Invalid password" && exit 1
initialPassword=/var/lib/jenkins/secrets/initialAdminPassword
cli=/var/cache/jenkins/war/WEB-INF/jenkins-cli.jar
url=http://localhost:8080
echo "Changing default password for admin..."
echo "jenkins.model.Jenkins.instance.securityRealm.createAccount('admin', '$password')" | \
  java -jar $cli -s $url -auth "admin:$(cat $initialPassword 2> /dev/null)" groovy =
#echo "$password" > /var/lib/jenkins/secrets/initialAdminPassword