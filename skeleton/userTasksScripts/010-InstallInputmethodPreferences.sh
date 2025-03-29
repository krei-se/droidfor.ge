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

MULTIUSERID=$DROIDFORGEAUTOPROVISIONMULTIUSERID
if [ -z MULTIUSERID ]; then
    MULTIUSERID=0
fi


if [ -f "skeleton/com.android.inputmethod.latin_preferences.xml" ]; then

    # if you're wondering, user_de stands for user_deviceEncryption

    package="com.android.inputmethod.latin"
    user_id=$(getUserIdFromPackageName "$package")

    echo "User ID for $package: $user_id"

    adb push skeleton/com.android.inputmethod.latin_preferences.xml /data/user_de/$MULTIUSERID/com.android.inputmethod.latin/shared_prefs/
    adb shell chmod 660 /data/user_de/$MULTIUSERID/com.android.inputmethod.latin/shared_prefs/com.android.inputmethod.latin_preferences.xml
    adb shell chown $user_id:$user_id /data/user_de/$MULTIUSERID/com.android.inputmethod.latin/shared_prefs/com.android.inputmethod.latin_preferences.xml
    adb shell "restorecon -R /data/user_de/$MULTIUSERID/com.android.inputmethod.latin/shared_prefs/"

    adb shell am force-stop com.android.inputmethod.latin
    adb shell ime set com.android.inputmethod.latin/.LatinIME

else

    echo "No inputmethod preferences in skeleton found. Skipping"

fi

