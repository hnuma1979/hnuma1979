#!/bin/bash -ue

# RESOURCE_GROUP    <your-resource-group>       input your resource group here
# DNS_ZONE           <your-dns-zone>            input your DNS zone here
# DNS_NAME           <your-dns-name>            default: _acme-challenge

az network dns record-set txt delete \
        -g ${RESOURCE_GROUP} -z ${DNS_ZONE} -n ${DNS_NAME:-_acme-challenge} --yes

