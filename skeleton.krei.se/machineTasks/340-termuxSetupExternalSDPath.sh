#!/bin/bash

functions/adbChecks.sh
if [ $? -ne 0 ]; then
    echo "One ore more ADB checks failed"
    exit 1
fi

source ./functions/getUserIdFromPackageName.sh

adb shell monkey -p com.termux -c android.intent.category.LAUNCHER 1

# Termux needs permission to read all files

    adb shell pm grant com.termux android.permission.READ_MEDIA_VISUAL_USER_SELECTED
    adb shell pm grant com.termux android.permission.READ_EXTERNAL_STORAGE
    adb shell pm grant com.termux android.permission.READ_MEDIA_IMAGES
    adb shell pm grant com.termux android.permission.READ_MEDIA_AUDIO
    adb shell pm grant com.termux android.permission.READ_MEDIA_VIDEO
    adb shell pm grant com.termux android.permission.WRITE_EXTERNAL_STORAGE
    adb shell pm grant com.termux android.permission.ACCESS_MEDIA_LOCATION


# Allow external Apps to communicate with Termux, needed for remotely running code inside termux

    adb shell "sed -i 's/^# *allow-external-apps *= *false/allow-external-apps=true/' /data/data/com.termux/files/home/.termux/termux.properties"
    adb shell "sed -i 's/^# *allow-external-apps *= *true/allow-external-apps=true/' /data/data/com.termux/files/home/.termux/termux.properties"

# run termux commands remotely, thanks to https://android.stackexchange.com/a/255725

    adb shell "echo 0 > /data/data/com.termux/files/home/commandDone"

    # run termux-setup-storage       // thats "Owner", not root
    adb shell /system/bin/am startservice --user 0 -n com.termux/com.termux.app.RunCommandService \
    -a com.termux.RUN_COMMAND \
    --es com.termux.RUN_COMMAND_PATH '/data/data/com.termux/files/usr/bin/bash' \
    --esa com.termux.RUN_COMMAND_ARGUMENTS '-c,"termux-setup-storage -y && echo 1 > ~/commandDone"' \
    --es com.termux.RUN_COMMAND_WORKDIR '/data/data/com.termux/files/home' \
    --ez com.termux.RUN_COMMAND_BACKGROUND 'false' \
    --es com.termux.RUN_COMMAND_SESSION_ACTION '0'

    # Loop until Termux command is completed
    while true; do
        command_done=$(adb shell cat /data/data/com.termux/files/home/commandDone)
        if [[ "$command_done" == "1" ]]; then
            echo "termux-setup-storage finished!"
            break
        fi
        sleep 1  # Check every second
    done

    adb shell "rm /data/data/com.termux/files/home/commandDone"

# try to find the external sd id:
    EXTERNALSDUUID=$(adb shell "ls /storage" | grep "-" | sed $'s/\x1b\[[0-9;]*m//g')

    if [ -z "$EXTERNALSDUUID" ]; then
        echo "No external SD found, skipping"
    fi

# if its found, write a symlink from /data/data/com.termux/files/home/externalsd to $EXTERNALSDPATH
if [ -n "$EXTERNALSDUUID" ]; then
    echo "External SD found at /storage/$EXTERNALSDUUID, symlinking from /data/data/com.termux/files/home/externalsd ..."
    
    package="com.termux"
    user_id=$(getUserIdFromPackageName "$package")
    
    # create symlink as the termux-user, this prevents most of selinux and owner-problems.
    adb shell "su $user_id -c 'ln -sf /storage/$EXTERNALSDUUID /data/data/com.termux/files/home/externalsd'"

    # just to be sure ;)
    adb shell "restorecon /data/data/com.termux/files/home/externalsd"

fi

