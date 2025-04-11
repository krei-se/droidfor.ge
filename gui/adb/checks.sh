#!/bin/bash

# combine script to check whether adb is installed, running, the current device is responding and set correctly

DF_ADB_PATH=$(command -v adb)
if [[ -n "$DF_ADB_PATH" ]]; then
    DF_ADB_INSTALLED=1
fi

if [[ -z "$DF_ADB_INSTALLED" ]]; then

    whiptail \
        --title "ADB missing" \
        --msgbox "ADB seems not installed, please install it (on Debian) using apt install android-tools-adb. While you're at it, make sure to install rsync too!" \
        10 $WT_WIDTH

    exit 1
fi

DF_RSYNC_PATH=$(command -v rsync)
if [[ -n "$DF_RSYNC_PATH" ]]; then
    DF_RSYNC_INSTALLED=1
fi


if [[ -z "$DF_RSYNC_INSTALLED" ]]; then

    whiptail \
        --title "rsync missing" \
        --msgbox "rsync seems not installed, please install it (on Debian) using apt install rsync" \
        10 $WT_WIDTH

    exit 1
fi
