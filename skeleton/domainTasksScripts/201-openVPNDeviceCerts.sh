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

adb shell "mkdir -p /sdcard/openvpn"

if [ -f "openvpnKeys/$DROIDFORGEAUTOPROVISIONDEVICENAMEFQDN.crt" ]; then
    adb push openvpnKeys/$DROIDFORGEAUTOPROVISIONDEVICENAMEFQDN.crt /sdcard/openvpn/device.crt
fi

if [ -f "openvpnKeys/$DROIDFORGEAUTOPROVISIONDEVICENAMEFQDN.key" ]; then
    adb push openvpnKeys/$DROIDFORGEAUTOPROVISIONDEVICENAMEFQDN.key /sdcard/openvpn/device.key
fi

# Try to get the ca cert from the TXT-record

URL=$(dig +short TXT "ed25519._tlsa.ca.${DROIDFORGEAUTOPROVISIONDOMAIN}" | sed 's/"//g')

# Check if URL was found
if [ -z "$URL" ];
    then
        echo "Error: No URL found for ca.$DROIDFORGEAUTOPROVISIONDOMAIN"
    else
        curl -o "/tmp/ca.$DROIDFORGEAUTOPROVISIONDOMAIN.crt" "$URL"
        adb push "/tmp/ca.$DROIDFORGEAUTOPROVISIONDOMAIN.crt" /sdcard/openvpn/ca.crt
fi


# clears the cache
adb shell pm clear de.blinkt.openvpn