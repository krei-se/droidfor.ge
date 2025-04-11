#!/bin/bash


GUI_DOMAIN_PKIPATH_ENTRY=$(whiptail --inputbox "Here you can change the path to your EasyRSA-PKI. I have no idea if variables work, so maybe use full paths. ./openvpnPKI will be in the projects root though" 10 $WT_WIDTH $DF_DOMAIN_PKIPATH --title "Change EasyRSA PKI path"  \
    3>&1 1>&2 2>&3
    )

EXIT_STATUS=$?

if [[ "$EXIT_STATUS" -eq 0 ]]; then

    export DF_DOMAIN_PKIPATH="$GUI_DOMAIN_PKIPATH_ENTRY"
    return 0

fi

if [[ "$EXIT_STATUS" -eq 1 ]]; then
    return 0
fi