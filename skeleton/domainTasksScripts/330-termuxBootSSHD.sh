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

# if .termux/boot/start-sshd exists, mark it executable
adb shell '[ -f /data/data/com.termux/files/home/.termux/boot/start-sshd ] && chmod +x /data/data/com.termux/files/home/.termux/boot/start-sshd'

# if termux boot was installed restart the termux:boot once
if adb shell pm list packages | grep -q "com.termux.boot"; then

    adb shell monkey -p com.termux.boot -c android.intent.category.LAUNCHER 1
    sleep 2
    adb shell input keyevent 3

    # if start-sshd was copied, run the script directly, as termux:boot will run it only after a reboot 
    if [ -f "skeleton/termux/.termux/boot/start-sshd" ]; then

        # allow termux to run in background. this is not an app permission, but deviceidle whitelist
        adb shell dumpsys deviceidle whitelist +com.termux
        
    
        # start the start-sshd command in boot
        adb shell "echo 0 > /data/data/com.termux/files/home/commandDone"
        
        # run termux command               // thats "Owner", not root
        adb shell /system/bin/am startservice --user 0 -n com.termux/com.termux.app.RunCommandService \
        -a com.termux.RUN_COMMAND \
        --es com.termux.RUN_COMMAND_PATH '/data/data/com.termux/files/usr/bin/bash' \
        --esa com.termux.RUN_COMMAND_ARGUMENTS '-c,"/data/data/com.termux/files/home/.termux/boot/start-sshd && echo 1 > ~/commandDone"' \
        --es com.termux.RUN_COMMAND_WORKDIR '/data/data/com.termux/files/home' \
        --ez com.termux.RUN_COMMAND_BACKGROUND 'false' \
        --es com.termux.RUN_COMMAND_SESSION_ACTION '0'

        # Loop until Termux command is completed
        while true; do
            command_done=$(adb shell cat /data/data/com.termux/files/home/commandDone)
            if [[ "$command_done" == "1" ]]; then
                echo "ran start-sshd"
                break
            fi
            sleep 1  # Check every second
        done

        adb shell "rm /data/data/com.termux/files/home/commandDone"
    
        sleep 2

        # test sshd port 8022 open
        nc -zv $DROIDFORGEAUTOPROVISIONDEVICENAMEFQDN 8022 &> /dev/null

        DROIDFORGEAUTOPROVISIONDEVICESSHRUNNING=false
        export DROIDFORGEAUTOPROVISIONDEVICESSHRUNNING

        if [[ $? -eq 0 ]]; then
            echo "✅ sshd port 8022 is open on the device"
            DROIDFORGEAUTOPROVISIONDEVICESSHRUNNING=true
            adb shell input keyevent 3

        else
            echo "❌ sshd port is closed"
            read -n 1 -s -r -p "SSHD Port is closed or the hostname was not found yet - press any key to continue..."
            
        fi

    fi

fi
