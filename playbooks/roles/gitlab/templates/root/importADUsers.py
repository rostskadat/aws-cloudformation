#!/usr/bin/python
# -*- coding: utf-8 -*-

#
# importADUsers.py
#
# This scripts imports users from an LDIF file into both gitlab and local LDAP server.
# Also, the script takes care of inluding the development users into the righ Gitlab
# development group, so they are able to see all the Gitlab projects.
#

import requests
import ldap
import sys
import ldif
import urllib

from ldif import LDIFParser, LDIFWriter

import ldap.modlist as modlist

GITLAB_HEADERS = { 'PRIVATE-TOKEN' : '{{GITLAB_PRIVATETOKEN}}' }
GITLAB_API_URI = 'http://{{}}/api/v4'

LDAP_URI = 'ldap://{{LDAPDNSName}}'
LDAP_SEARCH_BASE = 'ou=People,{{LDAPRootDC}}'
LDAP_USERNAME = '{{LDAPManagerDN}}'
LDAP_PASSWORD = '{{LDAPManagerPassword}}'


# Adds a development user to Gitlab server and to Gitlab's Development group
#
def addUser2Gitlab(entry, isDeveloper=True):
    data = {
        'email': entry['mail'][0],
        'extern_uid': entry['uid'][0].upper(),
        'provider': 'ldapmain',
        'name': entry['givenName'][0] + " " + entry['sn'][0],
        'username': entry['uid'][0].upper(),
        'password': '12345678',
        'external': 'true',
        'can_create_group': 'false',
        'skip_confirmation': 'true',
        'projects_limit': 0
        }
    print (data)
    r = requests.post(GITLAB_API_URI + '/users', data, headers=headers, verify=False)
    print("User " + entry['mail'][0] + " added to Gitlab: " + r.text)

    # Find id of the created used
    r = requests.get(GITLAB_API_URI + '/users?search=' + entry['mail'][0], headers=GITLAB_HEADERS, verify=False)
    result = r.json()

    try:
        uid = result[0]['id']
    except Exception as e:
        uid = -1
        pass

    # If the user to be added is a developer add it to the Developers group
    if isDeveloper:
        if 200 == r.status_code:
            data = {
                'id': 'Developers',
                'user_id': uid,
                'access_level': 30
            }

            # Add the created user to the Developers group
            r = requests.post(GITLAB_API_URI + '/groups/Developers/members', data, headers=headers, verify=False)
            print("User added to Developers group " + r.text)
            # Ex-developers are blocked at Gitlab level so they cannot create/delete/browse projects
    else:
        r = requests.put(GITLAB_API_URI + '/users/' + str(uid) + '/block', headers=headers, verify=False)
        print("Ex-developer user blocked " + r.text)


# Adds former developers to our local LDAP and Gitlab server, but not to
# Gitlab's Developers group since they are no longer active.
# former developers are imported from a static ldif file
#
def addADUsers():
    try:
        localLDAP = ldap.initialize(LDAP_URI)

        localLDAP.simple_bind_s(LDAP_USERNAME, LDAP_PASSWORD)
        localLDAP.protocol_version = ldap.VERSION3

        ldif_file = urllib.urlopen('import.ldif')
        parser = ldif.LDIFRecordList(ldif_file)
        parser.parse()

        for dn, entry in parser.all_records:

            attrs = {}

        if 'mail' in entry and 'uid' in entry:
            attrs['name'] = entry['uid']
            attrs['mail'] = entry['mail']
            attrs['givenName'] = entry['displayName']
            attrs['sn'] = ['']
        attrs['uid'] = entry['uid']
        addUser2Gitlab(attrs)

    except ldap.LDAPError as e:
        print("Adding development users failed: ")
        print('LDAPError: %s.' % e)
    finally:
        localLDAP.unbind_s()


# Adds a development user to our local OpenLDAP server
#
def addUser2LDAP(entry):
    if 'sAMAccountName' in entry and 'sn' in entry:
        try:
            localLDAP = ldap.initialize(LDAP_URI)
            localLDAP.simple_bind_s(LDAP_USERNAME, LDAP_PASSWORD)
            localLDAP.protocol_version = ldap.VERSION3
            dn = "cn=" + entry['name'][0].upper() + "," + LDAP_SEARCH_BASE
            attrs = {}

            attrs['objectclass'] = ['top', 'person', 'organizationalPerson', 'inetOrgPerson']
            attrs['cn'] = entry['name'][0].upper()
            attrs['userPassword'] = '12345678'
            attrs['displayName'] = entry['givenName'][0] + " " + entry['sn'][0]
            attrs['mail'] = entry['mail'][0]
            attrs['uid'] = entry['name'][0].upper()
            attrs['sn'] = entry['name'][0].upper()
            attrs['employeeType'] = 'developer'

            ldif = modlist.addModlist(attrs)
            localLDAP.add_s(dn, ldif)
            print ("User " + entry['name'][0].upper() + " added successfully")

        except ldap.LDAPError as e:
            print("Adding user " + entry['name'][0].upper() + " failed: ")
            print('LDAPError: %s.' % e)
        finally:
            localLDAP.unbind_s()

def main():
    addADUsers()

if __name__ == '__main__':
    sys.exit(main())

