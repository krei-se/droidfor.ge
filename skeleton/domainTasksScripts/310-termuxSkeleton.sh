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

# if .termux/boot/startsshd.sh exists, mark it executable
adb shell '[ -f /data/data/com.termux/files/home/.termux/boot/startsshd.sh ] && chmod +x /data/data/com.termux/files/home/.termux/boot/startsshd.sh'

# startsshd will run wakelock, enable

# if the skeleton includes a domainSetup.sh, mark it executable on the phone, then run it via termux

if [ -f skeleton/termux/domainSetup.sh ]; then

    # better be safe than sorry
    adb shell "chmod +x /data/data/com.termux/files/home/domainSetup.sh"

    adb shell "sed -i 's/^# *allow-external-apps *= *false/allow-external-apps=true/' /data/data/com.termux/files/home/.termux/termux.properties"
    adb shell "sed -i 's/^# *allow-external-apps *= *true/allow-external-apps=true/' /data/data/com.termux/files/home/.termux/termux.properties"

    adb logcat -c  # Clear logs

    adb shell "echo 0 > /data/data/com.termux/files/home/commandDone"

    # run termux command               // thats "Owner", not root
    adb shell /system/bin/am startservice --user 0 -n com.termux/com.termux.app.RunCommandService \
    -a com.termux.RUN_COMMAND \
    --es com.termux.RUN_COMMAND_PATH '/data/data/com.termux/files/usr/bin/bash' \
    --esa com.termux.RUN_COMMAND_ARGUMENTS '-c,"/data/data/com.termux/files/home/domainSetup.sh && echo 1 > ~/commandDone"' \
    --es com.termux.RUN_COMMAND_WORKDIR '/data/data/com.termux/files/home' \
    --ez com.termux.RUN_COMMAND_BACKGROUND 'false' \
    --es com.termux.RUN_COMMAND_SESSION_ACTION '0'

    # Loop until Termux command is completed
    while true; do
        command_done=$(adb shell cat /data/data/com.termux/files/home/commandDone)
        if [[ "$command_done" == "1" ]]; then
            echo "domainSetup.sh finished!"
            break
        fi
        sleep 1  # Check every second
    done

fi
