#!/bin/bash

# output function

run_termux_command_on_device() {

    COMMAND=$1
    MULTIUSERID=$2

    # This is totally dirty, but it works and is kinda safe, but please use ssh where possible lol

    adb shell "echo \"$COMMAND\" > /data/data/com.termux/files/home/termuxRemoteCommand"

    adb shell "echo \"echo 1 > /data/data/com.termux/files/home/termuxRemoteCommand\" >> /data/data/com.termux/files/home/termuxRemoteCommand"

    adb shell /system/bin/am startservice --user ${MULTIUSERID} -n com.termux/com.termux.app.RunCommandService \
    -a com.termux.RUN_COMMAND \
    --es com.termux.RUN_COMMAND_PATH '/data/data/com.termux/files/usr/bin/bash' \
    --esa com.termux.RUN_COMMAND_ARGUMENTS "/data/data/com.termux/files/home/termuxRemoteCommand" \
    --es com.termux.RUN_COMMAND_WORKDIR '/data/data/com.termux/files/home' \
    --ez com.termux.RUN_COMMAND_BACKGROUND 'false' \
    --es com.termux.RUN_COMMAND_SESSION_ACTION '0'


    # Loop until Termux command is completed
    while true; do
        command_done=$(adb shell cat /data/data/com.termux/files/home/termuxRemoteCommand)
        if [[ "$command_done" == "1" ]]; then
            echo "${COMMAND} finished!"
            break
        fi
        sleep 1  # Check every second
    done

    adb shell "rm /data/data/com.termux/files/home/termuxRemoteCommand"



}