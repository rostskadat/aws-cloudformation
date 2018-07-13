# A toolchain for the masses

## Description

These stack create a build toolchain based on 
1. [Gitlab](https://about.gitlab.com/)
2. [Artifactory](https://jfrog.com/artifactory/)
3. [Sonarqube](https://www.sonarqube.org/)
4. [Jenkins](https://jenkins.io/)

![Build infrastructure](./images/build.png)

## Installation Guide
1. These templates should be launched in order. You must have previously run the [`01-vpc.yaml`](../) templates [![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home#/stacks/new?stackName=01-vpc&templateURL=https://raw.githubusercontent.com/rostskadat/aws-cloudformation/master/stacks/01-vpc.yaml)
2. Launch the LDAP stack [![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home#/stacks/new?stackName=01-openldap&templateURL=https://raw.githubusercontent.com/rostskadat/aws-cloudformation/master/stacks/01-openldap.yaml)

# HOWTO connect to your JENKINS master from your corporate network

In your jumping host edit your `.ssh/config` to read:

```
Host aws-bastion
  HostName YOUR_PUBLIC_BASTION_DNS
  User ec2-user
  ProxyCommand /usr/bin/nc --proxy-type http --proxy proxy_hostname:3128 %h %p
  IdentityFile ~/.ssh/id_rsa
  ServerAliveInterval 300
  ServerAliveCountMax 2
```

Then launch the following commands: 

```
# First open the HTTP tunnel through your corporate proxy to the port of the public ELB (80)
jumping_host> ssh -CnfNL 4567:{{JenkinsDNSName}}:{{JenkinsListenerPort}} aws-bastion
# Then also open a tunnel toward the TCP ELB (8080)
jumping_host> ssh -CnfNL 49817:{{JenkinsDNSNameJNPL}}:{{JenkinsListenerJNPLPort}} aws-bastion
```

Then in your slave's `/etc/init.d/jenkins-swarm-client` make sure that you specify the `SWARM_MASTER` as  

```
SWARM_MASTER=http://jumping_host:4567
```

