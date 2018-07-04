// Inspired from https://github.com/samrocketman/jenkins-bootstrap-shared
import hudson.security.LDAPSecurityRealm
import hudson.util.Secret
import jenkins.model.Jenkins
import jenkins.model.IdStrategy
import jenkins.security.plugins.ldap.LDAPConfiguration

if(!(Jenkins.instance.securityRealm instanceof LDAPSecurityRealm)) {
  LDAPConfiguration conf = new LDAPConfiguration(
    '{{DNSName}}:{{LDAPPort}}',
    '{{RootDC}}',
    false,
    '{{ManagerDN}}',
    Secret.fromString('{{LDAPManagerPassword}}'))
  conf.userSearchBase = 'ou=People'
  conf.userSearch = 'uid={0}'
  conf.groupSearchBase = 'ou=Group'
  conf.displayNameAttributeName = 'displayName'
  conf.mailAddressAttributeName = 'mail'
  List<LDAPConfiguration> configurations = [conf]
  Jenkins.instance.securityRealm = new LDAPSecurityRealm(
    configurations,
    false,
    null,
    IdStrategy.CASE_INSENSITIVE,
    IdStrategy.CASE_INSENSITIVE)
  Jenkins.instance.save()
} else {
  println 'Nothing changed.  LDAP security realm already configured.'
}
println 'LDAP configured...'