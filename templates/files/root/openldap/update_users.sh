#!/bin/bash
#
# FILE: update_users.sh
#
# DESCRIPTION: This script will
#
RootDC="{{RootDC}}"
ManagerPassword="{{ManagerPassword}}"
LDAPUsersLdif="{{LDAPUsersLdif}}"
[ -z "$ldapUsersLdif" ] && echo "Invalid LDAPUsersLdif" && exit 1

echo "Loading initial LDIF user database from ${LDAPUsersLdif}"

aws s3 cp "${LDAPUsersLdif}" /root/openldap/import.ldif

ldapsearch -x -LLL -D "cn=Manager,${RootDC}" -w "${ManagerPassword}" -H ldapi:/// -b "${RootDC}" 2> /dev/null | \
awk -F": " '$1~/^\s*dn/{print $2}' > /root/openldap/to_delete.txt
[ -s /root/openldap/to_delete.txt ] && ldapdelete -r -D "cn=Manager,${RootDC}" -w "${ManagerPassword}" -H ldapi:/// -f /root/openldap/to_delete.txt
ldapadd -x -D "cn=Manager,${RootDC}" -w "${ManagerPassword}" -H ldapi:/// -f /root/openldap/import.ldif