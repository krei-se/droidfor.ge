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

source ./functions/getUserIdFromPackageName.sh

# clear cache and data to make sure the script works from a fresh install
    adb shell pm clear com.termux

# Monkey start the app
    adb shell monkey -p com.termux -c android.intent.category.LAUNCHER 1

echo "The Termux app should come up now, if you want to make sure all works, unlock the screen and watch the magic"
read -n 1 -s -r -p "Make sure the screen is unlocked and termux is opened, then press any key to continue..."

# push initial skeleton
    adb push skeleton/termux/. /data/data/com.termux/files/home/

# fix permissions to termux' user
    package="com.termux"
    user_id=$(getUserIdFromPackageName "$package")

    echo "User ID for $package: $user_id"

    adb shell chown -R $user_id:$user_id /data/data/com.termux/files/home/

# set the normal apt repository as its in Germany, Falkenstein
    echo -e "# This file is sourced by pkg\n# Termux's origin repo, hosted in Falkenstein, Germany\nWEIGHT=1\nMAIN=\"https://packages.termux.dev/apt/termux-main\"\nROOT=\"https://packages.termux.dev/apt/termux-root\"\nX11=\"https://packages.termux.dev/apt/termux-x11\"" > /tmp/chosen_mirrors
    adb push /tmp/chosen_mirrors /data/data/com.termux/files/usr/etc/termux/chosen_mirrors 


    adb shell "echo 'deb https://packages.termux.dev/apt/termux-main stable main' > /data/data/com.termux/files/usr/etc/apt/sources.list"

# run termux commands remotely, thanks to https://android.stackexchange.com/a/255725

    adb shell "sed -i 's/^# *allow-external-apps *= *false/allow-external-apps=true/' /data/data/com.termux/files/home/.termux/termux.properties"
    adb shell "sed -i 's/^# *allow-external-apps *= *true/allow-external-apps=true/' /data/data/com.termux/files/home/.termux/termux.properties"

    adb logcat -c  # Clear logs

    adb shell "echo 0 > /data/data/com.termux/files/home/commandDone"

    # pkg update
    adb shell /system/bin/am startservice --user 0 -n com.termux/com.termux.app.RunCommandService \
    -a com.termux.RUN_COMMAND \
    --es com.termux.RUN_COMMAND_PATH '/data/data/com.termux/files/usr/bin/bash' \
    --esa com.termux.RUN_COMMAND_ARGUMENTS '-c,"pkg update && yes | pkg upgrade -y && echo 1 > ~/commandDone"' \
    --es com.termux.RUN_COMMAND_WORKDIR '/data/data/com.termux/files/home' \
    --ez com.termux.RUN_COMMAND_BACKGROUND 'false' \
    --es com.termux.RUN_COMMAND_SESSION_ACTION '0'

    # Loop until Termux command is completed
    while true; do
        command_done=$(adb shell cat /data/data/com.termux/files/home/commandDone)
        if [[ "$command_done" == "1" ]]; then
            echo "Update finished!"
            break
        fi
        sleep 1  # Check every second
    done
