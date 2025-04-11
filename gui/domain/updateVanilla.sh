#!/bin/bash

source ./gui/adb/checks.sh

source ./gui/adb/checkForRoot.sh

if whiptail \
    --title "Get 🥼 Vanilla Settings for the Settings-Diff" \
    --yesno "You already seem to have a Vanilla-Settings dump! We can overwrite this, but make sure you actually use a fresh device.
You need 🥼 Vanilla Settings to create the Diff for updating settings on new devices.\n
Workflow:\n
- Connect a fresh lineage-device and dump the 🥼 Vanilla Settings
- Then change Settings how you like them on the device, then dump these as Skeleton-Settings to create a diff that will be used to easily apply Settings to all devices in your Domain

If you want to REGRAB 🥼 Vanilla Settings to skeleton.$DF_DOMAIN_FQDN/vanillaSettingsDump/, press Yes!" \
    30 $WT_WIDTH; then
        
        if [[ $DF_MACHINE_HASROOT ]]; then

            adb -s $DF_MACHINE_ADBID shell settings list global > skeleton.$DF_DOMAIN_FQDN/vanillaSettingsDump/settingsGlobal
            adb -s $DF_MACHINE_ADBID shell settings list secure > skeleton.$DF_DOMAIN_FQDN/vanillaSettingsDump/settingsSecure
            adb -s $DF_MACHINE_ADBID shell settings list system > skeleton.$DF_DOMAIN_FQDN/vanillaSettingsDump/settingsSystem

        else

            whiptail \
                --title "ADB-Root still missing?" \
                --msgbox "You somehow managed to reach this without ADB root - please install and check Magisk on the device!"

        fi

fi

return 0