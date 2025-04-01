#!/bin/bash

functions/adbChecks.sh
if [ $? -ne 0 ]; then
    echo "One ore more ADB checks failed"
    exit 1
fi

source ./functions/getUserIdFromPackageName.sh

cp skeleton/userHome/* $DROIDFORGEAUTOPROVISIONUSERHOME/.android


mkdir -p "$DROIDFORGEAUTOPROVISIONUSERHOME/.android/devices/$DROIDFORGEAUTOPROVISIONDEVICENAMEFQDN"

if [ ! -f $DROIDFORGEAUTOPROVISIONUSERHOME/.android/devices/$DROIDFORGEAUTOPROVISIONDEVICENAMEFQDN/applist ]; then
    cp skeleton/userHome/applist.example    $DROIDFORGEAUTOPROVISIONUSERHOME/.android/devices/$DROIDFORGEAUTOPROVISIONDEVICENAMEFQDN/applist
fi
