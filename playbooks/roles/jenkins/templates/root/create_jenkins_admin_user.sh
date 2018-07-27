#!/bin/bash

LDAPDNSName="{{LDAPDNSName}}"
LDAPPort="{{LDAPPort}}"
LDAPRootDC="{{LDAPRootDC}}"
LDAPManagerDN="{{LDAPManagerDN}}"
LDAPManagerPassword="{{LDAPManagerPassword}}"

[ -z "$LDAPDNSName" ] && echo "Invalid LDAPDNSName" && exit 1
[ -z "$LDAPPort" ] && echo "Invalid LDAPPort" && exit 1
[ -z "$LDAPRootDC" ] && echo "Invalid LDAPRootDC" && exit 1
[ -z "$LDAPManagerDN" ] && echo "Invalid LDAPManagerDN" && exit 1
[ -z "$LDAPManagerPassword" ] && echo "Invalid LDAPManagerPassword" && exit 1

exists=$(ldapsearch -x -LLL -D "${LDAPManagerDN}" -w "${LDAPManagerPassword}" -H ldap://${LDAPDNSName}:${LDAPPort}/ -b "ou=People,${LDAPRootDC}" -s sub 'uid=admin')
if [ -z "$exists" ]; then
    echo "Creating Jenkins Admin User in LDAP..."
    ldapadd -c -x -D "${LDAPManagerDN}" -w "${LDAPManagerPassword}" -H ldap://${LDAPDNSName}:${LDAPPort}/ -f /root/admin_user.ldif
else
    echo "Jenkins Admin User already exists in LDAP..."
fi