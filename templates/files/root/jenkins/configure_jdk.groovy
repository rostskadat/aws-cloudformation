import jenkins.model.Jenkins
import hudson.model.JDK
jdk = new JDK('java-1.8.0', '/etc/alternatives/java_sdk');
Jenkins.instance.setJDKs([jdk])
println 'JDK configured...'
