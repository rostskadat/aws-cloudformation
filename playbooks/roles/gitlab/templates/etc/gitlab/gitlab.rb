external_url 'https://{{ExternalUrl}}'
git_data_dirs({
    'default': {
        'path': '/mnt/application/data'
    }
})

#
# DB Settings
#
postgresql['enable'] = false
gitlab_rails['db_adapter'] = 'postgresql'
gitlab_rails['db_encoding'] = 'utf8'
gitlab_rails['db_host'] = '{{DBEndpointAddress}}'
gitlab_rails['db_port'] = {{DBEndpointPort}}
gitlab_rails['db_username'] = '{{DBAdminUsername}}'
gitlab_rails['db_password'] = '{{DBAdminPassword}}'

#
# SMTP Settings
#
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "{{SmtpHostname}}"
gitlab_rails['smtp_port'] = 587
gitlab_rails['smtp_user_name'] = "{{SmtpUsername}}"
gitlab_rails['smtp_password'] = "{{SmtpPassword}}"
#gitlab_rails['smtp_domain'] = "yourdomain.com"
gitlab_rails['smtp_authentication'] = "login"
gitlab_rails['smtp_enable_starttls_auto'] = true
gitlab_rails['gitlab_email_from'] = '{{GitlabAdminEmail}}'
gitlab_rails['gitlab_email_reply_to'] = '{{GitlabAdminEmail}}'

#
# LDAP Settings
#
gitlab_rails['ldap_enabled'] = true
gitlab_rails['ldap_servers'] = {
    'main' => { 
        'label' => 'OpenLDAP',
        'host' => '{{LDAPDNSName}}',
        'port' => {{LDAPPort}},
        'uid' => 'uid',
        'bind_dn' => '{{LDAPManagerDN}}',
        'password' => '{{LDAPManagerPassword}}',
        'encryption' => 'plain',
        'verify_certificates' => false,
        'active_directory' => false,
        'allow_username_or_email_login' => false,
        'lowercase_usernames' => false,
        'block_auto_created_users' => false,
        'base' => 'ou=People,{{LDAPRootDC}}',
        'user_filter' => '(objectclass=person)'
    }
}