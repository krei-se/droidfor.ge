#!/bin/bash

export DF_DOMAIN_FQDN=$(hostname -d)

if [[ -n "$DF_DOMAIN_FQDN" ]]; then
    source ./gui/domain/autodetectServices.sh
fi


return 0