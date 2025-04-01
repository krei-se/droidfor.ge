#!/bin/bash

functions/adbChecks.sh
if [ $? -ne 0 ]; then
    echo "One ore more ADB checks failed"
    exit 1
fi

source ./functions/getUserIdFromPackageName.sh

adb shell "mkdir -p /sdcard/openvpn"
adb push skeleton/openvpn/* /sdcard/openvpn/


# clears openvpn data
adb shell pm clear de.blinkt.openvpn