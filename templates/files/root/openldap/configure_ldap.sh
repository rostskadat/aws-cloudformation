#!/bin/bash
#
# FILE: configure_ldap.sh
#
# DESCRIPTION: This script will
#

RootDC="{{RootDC}}"
ManagerPassword="{{ManagerPassword}}"
LDAPUsersLdif="{{LDAPUsersLdif}}"
[ -z "${ManagerPassword}" ] && echo "Invalid ManagerPassword" && exit 1
[ -z "${RootDC}" ] && echo "Invalid RootDC" && exit 1

# BEWARE the 'dn' line should be equals to the file found in /etc/openldap/slapd.d/cn=config
ldapmodify -Q -Y EXTERNAL -H ldapi:/// <<EOF
dn: olcDatabase={2}bdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: $rootDC
EOF

# Changing the root DN
echo "Changing olcRootDN to 'cn=Manager,${RootDC}'..."
ldapmodify -Q -Y EXTERNAL -H ldapi:/// <<EOF
dn: olcDatabase={2}bdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=Manager,${RootDC}
EOF

# Adding the Root password
echo "Changing olcRootPW..."
ldapmodify -Q -Y EXTERNAL -H ldapi:/// <<EOF
dn: olcDatabase={2}bdb,cn=config
changetype: modify
add: olcRootPW
olcRootPW: ${ManagerPassword}
EOF

# Loading the initial users
[ ! -z "${LDAPUsersLdif}" ] && /root/openldap/update_users.sh
