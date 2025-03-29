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


adb shell pm grant com.termux android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
adb shell pm grant com.termux android.permission.WAKE_LOCK


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

    adb shell "rm /data/data/com.termux/files/home/commandDone"

fi

adb shell input keyevent 3