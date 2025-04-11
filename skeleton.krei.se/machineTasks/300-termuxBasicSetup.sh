#!/bin/bash

functions/adbChecks.sh
if [ $? -ne 0 ]; then
    echo "One ore more ADB checks failed"
    exit 1
fi

source ./functions/getUserIdFromPackageName.sh

# clear cache and data to make sure the script works from a fresh install - removed in prod
#    echo "Clearing data and cache for termux:"
#    adb shell pm clear com.termux
#    echo "Clearing data and cache for termux-boot:"
#    adb shell pm clear com.termux.boot

# Allow notifications, if you want to see all permissions,
    # just diff this before and after applying the new permissions:

    # adb shell dumpsys package com.termux | grep "requested permissions:" -A 100

    #run adb shell pm list permissions -g com.termux
    #run adb shell pm list permissions -d | grep com.termux
    
    adb shell pm grant com.termux android.permission.POST_NOTIFICATIONS


# Monkey start the app
    adb shell monkey -p com.termux -c android.intent.category.LAUNCHER 1

    echo "The Termux app should come up now, if you want to make sure all works, unlock the screen and watch the magic"

    echo "Waiting 5 seconds for termux to bootstrap ..."
    sleep 5

#read -n 1 -s -r -p "Make sure the screen is unlocked and termux is opened, then press any key to continue..."


# fix permissions to termux' user
    package="com.termux"
    user_id=$(getUserIdFromPackageName "$package")
    uid=$(getUidFromPackageName "$package")

    echo "User for $package: $user_id"
    echo "UID for $package: $uid"
    
#    adb shell chown -R $user_id:$user_id /data/data/com.termux/files/home/

# set the normal apt repository as its in Germany, Falkenstein
    adb shell ln -sf /data/data/com.termux/files/usr/etc/termux/mirrors/europe/packages.termux.dev /data/data/com.termux/files/usr/etc/termux/chosen_mirrors
    adb shell chown -R $user_id:$user_id /data/data/com.termux/files/usr/etc/termux/chosen_mirrors
    adb shell "restorecon /data/data/com.termux/files/usr/etc/termux/chosen_mirrors"

    adb shell "echo 'deb https://packages.termux.dev/apt/termux-main stable main' > /data/data/com.termux/files/usr/etc/apt/sources.list"
    adb shell chown -R $user_id:$user_id /data/data/com.termux/files/usr/etc/apt/sources.list
    
    # not needed, but its good if you see this more on google. Fixes SELinux issues that will drive you MAD
    adb shell "restorecon /data/data/com.termux/files/usr/etc/apt/sources.list"

# Allow external Apps to communicate with Termux, needed for remotely running code inside termux

    adb shell "sed -i 's/^# *allow-external-apps *= *false/allow-external-apps=true/' /data/data/com.termux/files/home/.termux/termux.properties"
    adb shell "sed -i 's/^# *allow-external-apps *= *true/allow-external-apps=true/' /data/data/com.termux/files/home/.termux/termux.properties"

# run termux commands remotely, thanks to https://android.stackexchange.com/a/255725

    adb shell "echo 0 > /data/data/com.termux/files/home/commandDone"

    # pkg update                       // thats "Owner", not root
    adb shell /system/bin/am startservice --user 0 -n com.termux/com.termux.app.RunCommandService \
    -a com.termux.RUN_COMMAND \
    --es com.termux.RUN_COMMAND_PATH '/data/data/com.termux/files/usr/bin/bash' \
    --esa com.termux.RUN_COMMAND_ARGUMENTS '-c,"id && TERMUX_PKG_NO_MIRROR_SELECT=true pkg update && yes | pkg upgrade -y && echo 1 > ~/commandDone"' \
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

    adb shell "rm /data/data/com.termux/files/home/commandDone"


adb shell input keyevent 3
