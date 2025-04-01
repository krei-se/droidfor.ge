#!/bin/bash

functions/adbChecks.sh
if [ $? -ne 0 ]; then
    echo "One ore more ADB checks failed"
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
    adb shell "restorecon /data/user_de/$MULTIUSERID/com.android.inputmethod.latin/shared_prefs/com.android.inputmethod.latin_preferences.xml"

    adb shell am force-stop com.android.inputmethod.latin
    adb shell ime set com.android.inputmethod.latin/.LatinIME

else

    echo "No inputmethod preferences in skeleton found. Skipping"

fi

