#!/bin/bash

getUserIdFromPackageName() {
    package_name=$1
    device=$2
    uid=$(adb -s $device:5555 shell pm list packages -U | grep "$package_name " | awk -F'uid:' '{print $2}' | tr -d '[:space:]' | cut -d',' -f1)

    if [[ -n "$uid" ]]; then
        # Extract the last three digits of the UID
        app_id=${uid: -3}
        echo "u0_a$app_id"
    else
        echo "Package not found or error retrieving user ID" >&2
        return 1
    fi
}


device=$1
app=$2

if [[ -z $1 || -z $2 ]]; then

    echo "Usage: restore.sh devicename.domain.tld tld.package.name";
    exit 1

fi

# Try to ping the device to check if it's reachable
if ! ping -c 1 -W 5 "$device" &> /dev/null; then
    echo "Device $device is unreachable. Did you provision it?"
    exit 1 
fi

# get the device folder
deviceFolder=./devices/$device

if [ ! -d $deviceFolder ]; then

    echo "DeviceFolder for $device not found. Name correct?"
    exit 1
fi

# Find the apk
apk=$deviceFolder/apks/$app.apk

if [ ! -f $apk ]; then

    echo "APK for $app not found. Package-Name correct?"
    exit 1

fi

# Check if a backup-folder exists
backupFolder=$deviceFolder/appData/$app

if [ ! -d $backupFolder ]; then

    echo "BackupData for $app not found. You find up to 3 backups there, just rename it to the Package-Name"
    exit 1

fi

# Check if a backup-folder exists
backupdeFolder=$deviceFolder/appData_de/$app

if [ ! -d $backupdeFolder ]; then

    echo "_de BackupData for $app not found. You find up to 3 backups there, just rename it to the Package-Name"
    exit 1

fi

read -n 1 -s -r -p "There seems to be an APK and BackupData present, you sure you want to restore $app on $device ? Then press any key to continue..."

adb -s "$device:5555" shell am force-stop "$app"
adb -s "$device:5555" shell pm clear "$app"

adb -s $device:5555 install "$apk"
user_id=$(getUserIdFromPackageName "$app" "$device")


adb -s $device:5555 push $backupFolder/.  /data/data/$app/
adb -s $device:5555 shell chown -R $user_id:$user_id /data/data/$app/
adb -s $device:5555 shell restorecon -R /data/data/$app/


adb -s $device:5555 push $backupdeFolder/.  /data/user_de/0/$app/
adb -s $device:5555 shell chown -R $user_id:$user_id /data/user_de/0/$app
adb -s $device:5555 shell restorecon -R /data/user_de/0/$app/

# Restart the app
adb -s "$device:5555" shell monkey -p "$app" -c android.intent.category.LAUNCHER 1

echo "should be fine now!"