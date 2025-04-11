#!/bin/bash

$DFROOTDIR/include/checks/checkAdminSoftware.sh
if [ $? -ne 0 ]; then
    echo "Please install adb, rsync and whiptail."
    echo "apt install android-tools-adb rsync whiptail"
    echo "... Exiting ..."
    exit 1
fi

$DFROOTDIR/include/checks/checkAdbDeviceConnection.sh
if [ $? -ne 0 ]; then
    echo "Device not connected! Exiting..."
    exit 1
fi

$DFROOTDIR/include/checks/checkAdbHasRoot.sh
if [ $? -ne 0 ]; then
    echo "Device is not running in adb rooted mode! Install and setup Magisk. Exiting..."
    exit 1
fi
