#!/bin/bash
#
# FILE: update_users.sh
#
# DESCRIPTION: This script will
#
RootDC="dc=allfundsbank,dc=com"
ManagerPassword="XRQtUZ7NKtD9EdV8"
LDAPUsersLdif="s3://cloudformation-eu-west-1-791682668801/ldap/export.ldif"
[ -z "${LDAPUsersLdif}" ] && echo "Invalid LDAPUsersLdif" && exit 1

echo "Downloading LDIF DB from ${LDAPUsersLdif}"
aws s3 cp "${LDAPUsersLdif}" /root/openldap/import.ldif

echo "Listing entries to remove..."
ldapsearch -x -LLL -D "cn=Manager,${RootDC}" -w "${ManagerPassword}" -H ldapi:/// -b "${RootDC}" 2> /dev/null | \
awk -F": " '$1~/^\s*dn/{print $2}' > /root/openldap/to_delete.txt
if [ -s /root/openldap/to_delete.txt ]; then
    echo "Deleting $(cat /root/openldap/to_delete.txt)"
    ldapdelete -r -D "cn=Manager,${RootDC}" -w "${ManagerPassword}" -H ldapi:/// -f /root/openldap/to_delete.txt
else
    echo "No entries to be deleted"
fi

echo "Adding entries from /root/openldap/import.ldif"
ldapadd -x -D "cn=Manager,${RootDC}" -w "${ManagerPassword}" -H ldapi:/// -f /root/openldap/import.ldif
