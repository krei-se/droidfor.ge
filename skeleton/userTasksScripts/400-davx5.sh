#!/bin/bash

# Please remember these will get called with working directory droidfor.ge/ not skeleton/taskScripts

functions/checkUserHasAdbAndRsyncLocally.sh
if [ $? -ne 0 ]; then
    echo "Please install adb and rsync. apt install android-tools-adb rsync Exiting..."
    exit 1
fi

functions/checkAdbDeviceConnection.sh
if [ $? -ne 0 ]; then
    echo "🍨Device not connected! Exiting..."
    exit 1
fi

functions/checkAdbHasRoot.sh
if [ $? -ne 0 ]; then
    echo "🍨Device is not running in adb rooted mode! Install and setup Magisk. Exiting..."
    exit 1
fi

source ./functions/getUserIdFromPackageName.sh

#     echo "Clearing data and cache for testruns:"
    adb shell pm clear at.bitfire.davdroid

# Permissions preset
adb shell pm grant at.bitfire.davdroid android.permission.POST_NOTIFICATIONS

adb shell pm grant at.bitfire.davdroid android.permission.READ_CALENDAR
adb shell pm grant at.bitfire.davdroid android.permission.WRITE_CALENDAR

adb shell pm grant at.bitfire.davdroid android.permission.READ_CONTACTS
adb shell pm grant at.bitfire.davdroid android.permission.WRITE_CONTACTS

adb shell pm grant at.bitfire.davdroid at.techbee.jtx.permission.WRITE
adb shell pm grant at.bitfire.davdroid at.techbee.jtx.permission.READ

# allow at.bitfire.davdroid to run in background. this is not an app permission, but deviceidle whitelist
adb shell dumpsys deviceidle whitelist +at.bitfire.davdroid

adb shell monkey -p at.bitfire.davdroid -c android.intent.category.LAUNCHER 1

sleep 2

adb shell am force-stop at.bitfire.davdroid

# Its FOSS, stop nagging me for donations
adb shell "grep -q 'time_nextDonationPopup' /data/data/at.bitfire.davdroid/shared_prefs/at.bitfire.davdroid_preferences.xml || sed -i '/<map>/a \ \ \ \ <long name=\"time_nextDonationPopup\" value=\"2100000000000\" />' /data/data/at.bitfire.davdroid/shared_prefs/at.bitfire.davdroid_preferences.xml"

adb shell monkey -p at.bitfire.davdroid -c android.intent.category.LAUNCHER 1

