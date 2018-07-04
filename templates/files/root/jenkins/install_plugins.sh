#!/bin/bash
#
# FILE: install_plugins.sh
#
# DESCRIPTION: This script will
#
exec > >(tee -a "/var/log/InstallApplication.log") 2> >(tee -a "/var/log/InstallApplication.log")
initialPassword=/var/lib/jenkins/secrets/initialAdminPassword
cli=/var/cache/jenkins/war/WEB-INF/jenkins-cli.jar
url=http://localhost:8080
/root/jenkins_wait.sh || (echo "Failed. Bailing out!" && exit 1)
echo "Configuring slaveAgentPort..."
sed -i -e "s@<slaveAgentPort>.*</slaveAgentPort>@<slaveAgentPort>49817</slaveAgentPort>@" /var/lib/jenkins/config.xml
echo "Configuring label..."
sed -i -e "s@<label>.*</label>@<label>master</label>@" /var/lib/jenkins/config.xml
service jenkins restart
/root/jenkins/wait.sh || (echo "Failed. Bailing out!" && exit 1)
echo "Installing plugins..."
java -jar $cli -s $url -auth "admin:$(cat $initialPassword 2> /dev/null)" install-plugin $(cat /root/plugins.txt | tr "\n" " ")
service jenkins restart
/root/jenkins/wait.sh || (echo "Failed. Bailing out!" && exit 1)
