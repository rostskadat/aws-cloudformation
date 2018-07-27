#!/bin/bash
#
# FILE: update_users.sh
#
# DESCRIPTION: This script will
#
RootDC="{{RootDC}}"
ManagerPassword="{{ManagerPassword}}"
LDAPUsersLdif="{{LDAPUsersLdif}}"
[ -z "${RootDC}" ] && echo "Invalid RootDC" && exit 1
[ -z "${ManagerPassword}" ] && echo "Invalid ManagerPassword" && exit 1
[ -z "${LDAPUsersLdif}" ] && echo "Invalid LDAPUsersLdif" && exit 1

echo "Downloading LDIF DB from ${LDAPUsersLdif}"
aws s3 cp "${LDAPUsersLdif}" /root/openldap/import.ldif


IFS=$'\n'
for user in `ldapsearch -x -H ldapi:/// -b "ou=People,${RootDC}" -D "cn=Manager,${RootDC}" -w "${ManagerPassword}" -LLL dn "(objectclass=inetOrgPerson)" 2> /dev/null`; do
    ldapmodify -x -H ldapi:/// -D "cn=Manager,${RootDC}" -w "${ManagerPassword}" 2>/dev/null << EOF
${user}
changetype: modify
replace: employeeType
employeeType: exdeveloper
EOF

done

for user in `grep "dn:" /root/openldap/import.ldif`; do
    ldapmodify -c -x -H ldapi:/// -D "cn=Manager,${RootDC}" -w "${ManagerPassword}" << EOF
${user}
changetype: modify
replace: employeeType
employeeType: developer
EOF

done

unset IFS

echo "Adding entries from /root/openldap/import.ldif"
ldapadd -c -x -D "cn=Manager,${RootDC}" -w "${ManagerPassword}" -H ldapi:/// -f /root/openldap/import.ldif
