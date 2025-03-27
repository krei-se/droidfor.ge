#!/bin/bash

./checkAdbDeviceConnection.sh
if [ $? -ne 0 ]; then
    echo "🥼 Vanilla device not connected! Exiting..."
    exit 1
fi

./checkAdbHasRoot.sh
if [ $? -ne 0 ]; then
    echo "🥼 Vanilla device is not running in adb rooted mode! Install and setup Magisk. Exiting..."
    exit 1
fi


echo ""

adb shell settings list global > skeleton/vanilla/settingsGlobal
adb shell settings list secure > skeleton/vanilla/settingsSecure
adb shell settings list system > skeleton/vanilla/settingsSystem

echo "Settings grabbed. Now make changes on the settings as you want them to be provisioned, then run ./createSkeletonSettingsDiff.sh"