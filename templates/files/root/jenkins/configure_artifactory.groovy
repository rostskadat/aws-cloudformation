import jenkins.model.Jenkins
import org.jfrog.hudson.*
artifactory = Jenkins.instance.getExtensionList('org.jfrog.hudson.ArtifactoryBuilder$DescriptorImpl')[0]
artifactory.useCredentialsPlugin = false;
artifactory.pushToBintrayEnabled = false;
artifactory.buildInfoProxyEnabled = false;
CredentialsConfig credentials = new CredentialsConfig('{{ArtifactoryAdminUsername}}', '{{ArtifactoryAdminPassword}}', 'ARTIFACTORY_CREDENTIALS')
ArtifactoryServer server = new ArtifactoryServer('ARTIFACTORY', 'http://{{ArtifactoryDNSName}}/artifactory', credentials, credentials, 300, true, 3);
artifactory.artifactoryServers = [ server ]
artifactory.save();
println 'Artifactory configured...'
