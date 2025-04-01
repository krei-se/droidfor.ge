#!/bin/bash

functions/adbChecks.sh
if [ $? -ne 0 ]; then
    echo "One ore more ADB checks failed"
    exit 1
fi

source ./functions/getUserIdFromPackageName.sh

adb shell "mkdir -p /sdcard/openvpn"

if [ -f "openvpnPKI/issued/$DROIDFORGEAUTOPROVISIONDEVICENAMEFQDN.crt" ]; then
    adb push openvpnPKI/issued/$DROIDFORGEAUTOPROVISIONDEVICENAMEFQDN.crt /sdcard/openvpn/device.crt
fi

if [ -f "openvpnPKI/private/$DROIDFORGEAUTOPROVISIONDEVICENAMEFQDN.key" ]; then
    adb push openvpnPKI/private/$DROIDFORGEAUTOPROVISIONDEVICENAMEFQDN.key /sdcard/openvpn/device.key
fi

# Try to get the ca cert from the TXT-record

URL=$(dig +short TXT "ed25519._tlsa.ca.${DROIDFORGEAUTOPROVISIONDOMAIN}" | sed 's/"//g')

# Check if URL was found
if [ -z "$URL" ];
    then
        echo "Error: No URL found for ca.$DROIDFORGEAUTOPROVISIONDOMAIN"
        echo "Make sure to copy a ca.crt via skeleton/openvpn"
    else
        curl -o "/tmp/ca.$DROIDFORGEAUTOPROVISIONDOMAIN.crt" "$URL"
        adb push "/tmp/ca.$DROIDFORGEAUTOPROVISIONDOMAIN.crt" /sdcard/openvpn/ca.crt
fi

# clears openvpn data
adb shell pm clear de.blinkt.openvpn