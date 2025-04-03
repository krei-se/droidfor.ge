#!/bin/bash

functions/adbChecks.sh
if [ $? -ne 0 ]; then
    echo "One ore more ADB checks failed"
    exit 1
fi

source ./functions/getUserIdFromPackageName.sh

adb shell "mkdir -p /sdcard/openvpn"

if [ -f "openvpnPKI/issued/$DEVICENAMEFQDN.crt" ]; then
    adb push openvpnPKI/issued/$DEVICENAMEFQDN.crt /sdcard/openvpn/device.crt
fi

if [ -f "openvpnPKI/private/$DEVICENAMEFQDN.key" ]; then
    adb push openvpnPKI/private/$DEVICENAMEFQDN.key /sdcard/openvpn/device.key
fi

# Try to get the ca cert from the TXT-record

URL=$(dig +short TXT "ed25519._tlsa.ca.${DOMAIN}" | sed 's/"//g')

# Check if URL was found
if [ -z "$URL" ];
    then
        echo "Error: No URL found for ca.$DOMAIN"
        echo "Make sure to copy a ca.crt via skeleton/openvpn"
    else
        curl -o "/tmp/ca.$DOMAIN.crt" "$URL"
        adb push "/tmp/ca.$DOMAIN.crt" /sdcard/openvpn/ca.crt
fi

# clears openvpn data
adb shell pm clear de.blinkt.openvpn