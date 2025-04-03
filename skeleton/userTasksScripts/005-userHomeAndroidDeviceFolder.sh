#!/bin/bash

functions/adbChecks.sh
if [ $? -ne 0 ]; then
    echo "One ore more ADB checks failed"
    exit 1
fi

source ./functions/getUserIdFromPackageName.sh

cp skeleton/userHome/* $USERHOME/.android


mkdir -p "$USERHOME/.android/devices/$DEVICENAMEFQDN"

if [ ! -f $USERHOME/.android/devices/$DEVICENAMEFQDN/applist ]; then
    cp skeleton/userHome/applist.example    $USERHOME/.android/devices/$DEVICENAMEFQDN/applist
fi
