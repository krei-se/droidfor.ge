#!/bin/bash

# Run adb devices command and capture output
OUTPUT=$(adb -s $DF_MACHINE_ADBID root 2>&1)

# Check if output matches expected messages
if [[ "$OUTPUT" == "restarting adbd as root" || "$OUTPUT" == "adbd is already running as root" ]]; then
    DF_HOST_HASADBROOT=1
else
    DF_HOST_HASADBROOT=0
    whiptail \
        --title "ADB not running in root mode" \
        --msgbox "ADB seems not to be running in root mode, actually you should never see this text!" \
        10 $WT_WIDTH

    return 1
fi

# Run adb devices command and capture output
OUTPUT=$(adb -s $DF_MACHINE_ADBID shell 'su -c "echo roottest"' 2>&1)

# Check if output matches expected messages
if [[ "$OUTPUT" == "roottest" ]]; then
    DF_MACHINE_HASROOT=1
else

    DF_MACHINE_HASROOT=0
    whiptail \
    --title "Device is not rooted?" \
    --msgbox "Your device seems to be not rooted or has Magisk ignore shell su - Please check whether Magisk is correctly installed\n
    If you missed to confirm Root-Access for Shell, you can reactive this in Magisk in the lower Tab 🛡️ Superuser" \
    10 $WT_WIDTH

    return 1

fi

export DF_HOST_HASADBROOT
export DF_MACHINE_HASROOT