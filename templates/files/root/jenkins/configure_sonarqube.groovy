import jenkins.model.Jenkins
import hudson.plugins.sonar.*
sonarqube = Jenkins.instance.getExtensionList('hudson.plugins.sonar.SonarGlobalConfiguration')[0]
sonarqube.buildWrapperEnabled = false;
SonarInstallation installation = new SonarInstallation('SONARQUBE', 'http://{{SonarqubeDNSName}}', '%sonarqubeToken%', null, null, null, null)
sonarqube.installations = [ installation ]
sonarqube.save();
println 'Sonarqube configured...'