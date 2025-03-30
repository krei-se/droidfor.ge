#!/bin/bash

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

cp skeleton/userHome/* $DROIDFORGEAUTOPROVISIONUSERHOME/.android


mkdir -p "$DROIDFORGEAUTOPROVISIONUSERHOME/.android/devices/$DROIDFORGEAUTOPROVISIONDEVICENAMEFQDN"

if [ ! -f $DROIDFORGEAUTOPROVISIONUSERHOME/.android/devices/$DROIDFORGEAUTOPROVISIONDEVICENAMEFQDN/applist ]; then
    cp skeleton/userHome/applist.example    $DROIDFORGEAUTOPROVISIONUSERHOME/.android/devices/$DROIDFORGEAUTOPROVISIONDEVICENAMEFQDN/applist
fi
