#!/bin/bash

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

DEVICENAMEFQDN=$1
USERACCOUNT=$2

echo "Device name to be adminProvisioned is $DEVICENAMEFQDN"

echo "User Account to be setup is $USERACCOUNT"

read -p "Are these settings correct? (y/n): " choice
    case "$choice" in
        y|Y )
            echo "Continuing adminProvisioning..."
            ;;
        n|N )
            echo "Exiting script."
            exit 1
            ;;
        * )
            echo "Invalid input. Exiting."
            exit 1
            ;;
    esac




echo "cOonidsfa"