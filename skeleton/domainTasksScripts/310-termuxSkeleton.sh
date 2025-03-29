#!/bin/bash

# Please remember these will get called with working directory droidfor.ge/ not skeleton/taskScripts

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

    adb shell monkey -p com.termux -c android.intent.category.LAUNCHER 1

# push initial skeleton
    adb push skeleton/termux/. /data/data/com.termux/files/home/

# This was a real tough one lol - SELinux
    adb shell "restorecon -R /data/data/com.termux/files/home/"

# fix permissions to termux' user
    package="com.termux"
    user_id=$(getUserIdFromPackageName "$package")
    uid=$(getUidFromPackageName "$package")


    echo "User for $package: $user_id"
    echo "UID for $package: $uid"

    adb shell "chown -R $user_id:$user_id /data/data/com.termux/files/home/"

# fix executable bit for all scripts

    adb shell "chmod +x /data/data/com.termux/files/home/*.sh"
    adb shell "restorecon -R /data/data/com.termux/files/home/"

adb shell input keyevent 3