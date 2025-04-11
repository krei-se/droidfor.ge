#!/bin/bash

functions/adbChecks.sh
if [ $? -ne 0 ]; then
    echo "One ore more ADB checks failed"
    exit 1
fi

source ./functions/getUserIdFromPackageName.sh

adb shell "setprop adb.tcp.port 5555"
adb shell "setprop persist.adb.tcp.port 5555"
# Yeah i know this be dirty but works
adb shell "su -c 'stop adbd; start adbd'"

sleep 2

#adb kill-server
adb wait-for-device
#adb root

sleep 2

echo "Your current TCP Port for ADB should output 5555, grabbing setting via adb getprop:"
adb shell "getprop adb.tcp.port"
echo "Your persisted TCP Port for ADB should output 5555, grabbing setting via adb getprop:"
adb shell "getprop persist.adb.tcp.port"

