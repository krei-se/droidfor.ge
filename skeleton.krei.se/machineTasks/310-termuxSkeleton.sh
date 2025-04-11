#!/bin/bash

functions/adbChecks.sh
if [ $? -ne 0 ]; then
    echo "One ore more ADB checks failed"
    exit 1
fi

source ./functions/getUserIdFromPackageName.sh

adb shell monkey -p com.termux -c android.intent.category.LAUNCHER 1

# push initial skeleton
    adb push skeleton/termux/. /data/data/com.termux/files/home/

# fix permissions to termux' user
    package="com.termux"
    user_id=$(getUserIdFromPackageName "$package")
    uid=$(getUidFromPackageName "$package")


    echo "User for $package: $user_id"
    echo "UID for $package: $uid"

    adb shell "chown -R $user_id:$user_id /data/data/com.termux/files/home/"

# fix selinux context, note restorecon -R will not work, you have to loop the files

    adb shell "find /data/data/com.termux/files/home/ -exec restorecon {} \;"

# fix executable bit for all sh scripts

    adb shell "find /data/data/com.termux/files/home/ -iname '*.sh' -exec chmod +x {} \;"

adb shell input keyevent 3