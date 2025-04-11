#!/bin/bash

DF_MACHINE_HOSTNAME=$(echo "$DF_MACHINE_FQDN" | cut -d'.' -f1)

GUI_MACHINE_NAME_ENTRY=$(whiptail --inputbox "Enter name for the device without the domain, for device.$DF_DOMAIN_FQDN simply enter device" 10 $WT_WIDTH $DF_MACHINE_HOSTNAME --title "Machine Name Entry"  \
    3>&1 1>&2 2>&3
    )


EXIT_STATUS=$?

if [[ "$EXIT_STATUS" -eq 0 ]]; then

    export DF_MACHINE_FQDN="${GUI_MACHINE_NAME_ENTRY}.${DF_DOMAIN_FQDN}"
    ./gui/machine/main.sh

fi

if [[ "$EXIT_STATUS" -eq 1 ]]; then
    ./gui/machine/main.sh
fi