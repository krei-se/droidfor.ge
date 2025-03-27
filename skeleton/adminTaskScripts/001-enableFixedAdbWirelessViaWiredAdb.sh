#!/bin/bash

# Please remember these will get called with working directory droidfor.ge/ not skeleton/taskScripts
./checkUserHasAdbAndRsyncLocally.sh
if [ $? -ne 0 ]; then
    echo "Please install adb and rsync. apt install android-tools-adb rsync Exiting..."
    exit 1
fi

./checkAdbDeviceConnection.sh
if [ $? -ne 0 ]; then
    echo "🍨Device not connected! Exiting..."
    exit 1
fi

./checkAdbHasRoot.sh
if [ $? -ne 0 ]; then
    echo "🍨Device is not running in adb rooted mode! Install and setup Magisk. Exiting..."
    exit 1
fi

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

