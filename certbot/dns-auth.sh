#!/bin/bash 

[   -z "$CERTBOT_VALIDATION"    ] && exit 0 # 
[   -z "$CERTBOT_TOKEN"         ] || exit 0 # 
[   -z "$RESOURCE_GROUP"        ] && exit 1 #
[   -z "$ZONE_NAME"             ] && exit 1 #

# _acme-challenge
az network dns record-set txt delete            \
    --resource-group    "$RESOURCE_GROUP"       \
    --zone-name         "$ZONE_NAME"            \
    --record-set-name   "_acme-challenge"

az network dns record-set txt add-record        \
    --resource-group    "$RESOURCE_GROUP"       \
    --zone-name         "$ZONE_NAME"            \
    --record-set-name   "_acme-challenge"       \
    --value             "$CERTBOT_VALIDATION"