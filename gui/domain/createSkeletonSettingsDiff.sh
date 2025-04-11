#!/bin/bash

source ./gui/adb/checks.sh
source ./gui/adb/checkForRoot.sh


if whiptail \
    --title "Create Settings-Diff" \
    --yesno "You seem to have Vanilla-Settings grabbed, so if you changed all Settings to your liking, now is the time to create a Diff you can use to setup all devices with your preferred Settings
If you want to continue, press Yes!" \
    30 $WT_WIDTH; then
        
        if [[ $DF_MACHINE_HASROOT ]]; then

            adb -s $DF_MACHINE_ADBID shell settings list global > /tmp/settingsGlobal
            adb -s $DF_MACHINE_ADBID shell settings list system > /tmp/settingsSystem
            adb -s $DF_MACHINE_ADBID shell settings list secure > /tmp/settingsSecure

            diff --new-line-format="%L" --old-line-format="" --unchanged-line-format="" skeleton.$DF_DOMAIN_FQDN/vanillaSettingsDump/settingsGlobal /tmp/settingsGlobal > skeleton.$DF_DOMAIN_FQDN/settingsGlobal
            diff --new-line-format="%L" --old-line-format="" --unchanged-line-format="" skeleton.$DF_DOMAIN_FQDN/vanillaSettingsDump/settingsSecure /tmp/settingsSecure > skeleton.$DF_DOMAIN_FQDN/settingsSecure
            diff --new-line-format="%L" --old-line-format="" --unchanged-line-format="" skeleton.$DF_DOMAIN_FQDN/vanillaSettingsDump/settingsSystem /tmp/settingsSystem > skeleton.$DF_DOMAIN_FQDN/settingsSystem


            # Remove settings that will change during setup usually like brightness and chargetime
            #   doze/sleep state
                sed -i '/^restart_nap_after_start/d' skeleton.$DF_DOMAIN_FQDN/settingsSecure
                #sed -i '/^night_display_activated/d' skeleton/settingsSecure
                sed -i '/^night_display_last_activated_time/d' skeleton.$DF_DOMAIN_FQDN/settingsSecure

            # Boot Count

                sed -i '/^boot_count/d' skeleton.$DF_DOMAIN_FQDN/settingsGlobal

            #   Screen Brightness
                sed -i '/^screen_brightness/d' skeleton.$DF_DOMAIN_FQDN/settingsSystem

            # Remove changed bluetooth and device name
                sed -i '/^device_name/d' skeleton.$DF_DOMAIN_FQDN/settingsGlobal
                sed -i '/^bluetooth_name/d' skeleton.$DF_DOMAIN_FQDN/settingsSecure

            # Remove android_id (whatever that is)

                sed -i '/^android_id/d' skeleton.$DF_DOMAIN_FQDN/settingsSecure

            # Remove time to full
                sed -i '/^time_to_full_millis/d' skeleton.$DF_DOMAIN_FQDN/settingsGlobal

            # Other stuff i noticed

                sed -i '/^network_watchlist_last_report_time/d' skeleton.$DF_DOMAIN_FQDN/settingsGlobal


            # Remove any attempt to bother the user with custom ringtones:

                sed -i '/sound=content:/d' skeleton.$DF_DOMAIN_FQDN/settingsGlobal
                sed -i '/sound=content:/d' skeleton.$DF_DOMAIN_FQDN/settingsSecure
                sed -i '/sound=content:/d' skeleton.$DF_DOMAIN_FQDN/settingsSystem
                            
            if whiptail \
                --title "Grab the current AOSP input xml ⌨️" \
                --yesno "You can now optionally also grab the input settings for the onboard-keyboard (this is technically a user-profile setting).
It can be applied on all devices/users later by a task. If you change your mind, just delete com.android.inputmethod.latin_preferences.xml in your skeleton.$DF_DOMAIN_FQDN.
If you want to grab the XML, press Yes!" \
                30 $WT_WIDTH; then
                        echo "saving com.android.inputmethod.latin_preferences.xml to skeleton/com.android.inputmethod.latin_preferences.xml"
                        adb -s $DF_MACHINE_ADBID pull /data/user_de/0/com.android.inputmethod.latin/shared_prefs/com.android.inputmethod.latin_preferences.xml skeleton.$DF_DOMAIN_FQDN/com.android.inputmethod.latin_preferences.xml
                        
            fi


            SETTINGS_SUMMARY="Changed in Settings Global: \n"
            SETTINGS_SUMMARY+="--------------------------- \n"

            SETTINGS_SUMMARY+=$(cat skeleton.$DF_DOMAIN_FQDN/settingsGlobal)
            SETTINGS_SUMMARY+="\n\n"

            SETTINGS_SUMMARY+="Changed in Settings Secure: \n"
            SETTINGS_SUMMARY+="--------------------------- \n"
            SETTINGS_SUMMARY+=$(cat skeleton.$DF_DOMAIN_FQDN/settingsSecure)
            SETTINGS_SUMMARY+="\n\n"

            SETTINGS_SUMMARY+="Changed in Settings System: \n"
            SETTINGS_SUMMARY+="--------------------------- \n"
            SETTINGS_SUMMARY+=$(cat skeleton.$DF_DOMAIN_FQDN/settingsSystem)
            SETTINGS_SUMMARY+="\n\n"

            SETTINGS_SUMMARY+="Settings-Diff saved to skeleton.$DF_DOMAIN_FQDN/settings/"

            whiptail --title "Created Settings-Diff" --msgbox "$SETTINGS_SUMMARY" $WT_HEIGHT $WT_WIDTH

            return 0

        else

            whiptail \
                --title "ADB-Root still missing?" \
                --msgbox "You somehow managed to reach this without ADB root - please install and check Magisk on the device!"

            return 1
        
        fi

fi

return 0


