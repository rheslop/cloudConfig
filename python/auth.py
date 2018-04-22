#!/usr/bin/python

# This authentication script has been shown to work with:
# OSP 10 / Keystone v2 [ 'overcloudrc' | 'stackrc' ]

import os

from keystoneauth1 import identity
from keystoneauth1 import session
from neutronclient.v2_0 import client

try:
    credentials = {}
    credentials['auth_url']   = os.environ['OS_AUTH_URL']
    credentials['username']   = os.environ['OS_USERNAME']
    credentials['password']   = os.environ['OS_PASSWORD']
    credentials['project_id'] = os.environ['OS_TENANT_NAME']

except KeyError:
    print("Authentication error. Did you source your authentication file?")
    exit()

authentication = identity.Password(auth_url        = credentials['auth_url'],
                                   username        = credentials['username'],
                                   password        = credentials['password'],
                                   project_name    = credentials['project_id'])

session0 = session.Session(authentication)
neutron = client.Client(session = session0)

# Example output

# print(neutron.list_networks())

netList = neutron.list_networks()
for i in range(len(netList['networks'])):
    name = netList['networks'][i]['name']
    print name

# print(neutron.list_ports())

