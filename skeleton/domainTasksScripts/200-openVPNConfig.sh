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

adb shell "mkdir -p /sdcard/openvpn"
adb push skeleton/openvpn/* /sdcard/openvpn/


# clears openvpn data
adb shell pm clear de.blinkt.openvpn