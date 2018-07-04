external_url 'http://{{ExternalUrl}}'
git_data_dirs({
    'default': {
        'path': '/mnt/application/data'
    }
})
                
postgresql['enable'] = false
gitlab_rails['db_adapter'] = 'postgresql'
gitlab_rails['db_encoding'] = 'utf8'
gitlab_rails['db_host'] = '{{EndpointAddress}}'
gitlab_rails['db_port'] = {{EndpointPort}}
gitlab_rails['db_username'] = '{{MasterUsername}}'
gitlab_rails['db_password'] = '{{DBMasterPassword}}'

gitlab_rails['ldap_enabled'] = true
gitlab_rails['ldap_servers'] = {
    'main' => { 
        'label' => 'OpenLDAP',
        'host' => '{{DNSName}}',
        'port' => {{LDAPPort}},
        'uid' => 'uid',
        'bind_dn' => '{{ManagerDN}}',
        'password' => '{{LDAPManagerPassword}}',
        'encryption' => 'plain',
        'verify_certificates' => false,
        'active_directory' => false,
        'allow_username_or_email_login' => false,
        'lowercase_usernames' => false,
        'block_auto_created_users' => false,
        'base' => 'ou=People,{{RootDC}}',
        'user_filter' => '(objectclass=person)'
    }
}