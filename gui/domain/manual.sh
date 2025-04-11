#!/bin/bash


GUI_DOMAIN_MANUAL_ENTRY=$(whiptail --inputbox "Enter the domain" 10 $WT_WIDTH $DF_DOMAIN_FQDN --title "Manual domain Entry"  \
    3>&1 1>&2 2>&3
    )


EXIT_STATUS=$?

if [[ "$EXIT_STATUS" -eq 0 ]]; then

    export DF_DOMAIN_FQDN="$GUI_DOMAIN_MANUAL_ENTRY"
    source ./gui/domain/autodetectServices.sh
    return 0

fi

if [[ "$EXIT_STATUS" -eq 1 ]]; then
    return 0
fi