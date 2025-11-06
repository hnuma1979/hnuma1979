#!/bin/bash -ue

# RESOURCE_GROUP    <your-resource-group>       input your resource group here
# DNS_ZONE           <your-dns-zone>            input your DNS zone here
# DNS_NAME           <your-dns-name>            default: _acme-challenge
# CERTBOT_VALIDATION <your-validation-token>    certbot will set this

az network dns record-set txt add-record \
        -g ${RESOURCE_GROUP} -z ${DNS_ZONE} -n ${DNS_NAME:-_acme-challenge} -v "$CERTBOT_VALIDATION"

sleep 1m