#!/bin/bash

functions/adbChecks.sh
if [ $? -ne 0 ]; then
    echo "One ore more ADB checks failed"
    exit 1
fi

source ./functions/getUserIdFromPackageName.sh


if [[ -n $(adb shell pm list packages |  grep -E "\borg.fdroid.fdroid") ]]; then

    echo "test non zero for line with grep -E"

fi

if [[ -n $(adb shell pm list packages |  grep -E "\borg.fdrofid.fdroid") ]]; then

    echo "test non zero for non with grep -E"

fi



if [[ -z $(adb shell pm list packages | grep "org.fdroitestd.fdroid") ]]; then

    echo "test zero for non"

fi



if [[ -n $(adb shell pm list packages | grep "org.fdroid.fdroid") ]]; then

    echo "FDroid Permissions"
    adb shell pm grant org.fdroid.fdroid android.permission.POST_NOTIFICATIONS

fi

if [[ -z $(adb shell pm list packages | grep "org.fdroitestd.fdroid") ]]; then

    echo "non-zero still triggers"

fi

if [[ -n $(adb shell pm list packages | grep "org.videolan.vlc") ]]; then

    echo "VLC Permissions"
    adb shell pm grant org.videolan.vlc android.permission.POST_NOTIFICATIONS

fi

if [[ -n $(adb shell pm list packages | grep "org.schabi.newpipe") ]]; then

    echo "NewPipe Permissions"

    adb shell pm grant org.schabi.newpipe android.permission.POST_NOTIFICATIONS

fi
