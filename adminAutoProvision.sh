#!/bin/bash

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


if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: $0 <devicename.domain.tld> <user@domain.tld>"
    exit 1
fi

DEVICENAMEFQDN=$1
USERACCOUNT=$2
USERNAME=$(echo "$USERACCOUNT" | cut -d'@' -f1)


# Check if DEVICENAMEFQDN has at least two dots (indicating a valid FQDN)
DOT_COUNT=$(echo "$DEVICENAMEFQDN" | awk -F'.' '{print NF-1}')

if [ "$DOT_COUNT" -lt 2 ]; then
    echo "Error: The provided DEVICENAMEFQDN '$DEVICENAMEFQDN' does not contain at least two dots (hostname and domain are required)."
    exit 1
fi

DEVICENAME=$(echo "$DEVICENAMEFQDN" | cut -d'.' -f1)
DOMAIN=$(echo "$DEVICENAMEFQDN" | cut -d'.' -f2-)

DROIDFORGEAUTOPROVISIONDOMAIN=$DOMAIN
export DROIDFORGEAUTOPROVISIONDOMAIN

echo -e "Device name to be adminProvisioned is \033[0;34m$DEVICENAMEFQDN\033[0m - derived Host \033[0;34m$DEVICENAME\033[0m in Domain \033[0;31m$DOMAIN\033[0m"

echo -e "User Account to be setup is \033[0;32m$USERACCOUNT\033[0m - derived Name \033[0;32m$USERNAME\033[0m"

read -p "Are these settings correct? (y/n): " choice
    case "$choice" in
        y|Y )
            echo "Continuing adminProvisioning..."
            ;;
        n|N )
            echo "Exiting script."
            exit 1
            ;;
        * )
            echo "Invalid input. Exiting."
            exit 1
            ;;
    esac

echo -e "Installing Initial Apps \n"

./installInitialApps.sh

read -n 1 -s -r -p "Make sure the device is rooted, then press any key to continue..."

echo -e "Checking if the device is rooted ... \n"

./checkAdbHasRoot.sh
if [ $? -ne 0 ]; then
    echo "🍨Device is not running in adb rooted mode! Install and setup Magisk. Exiting..."
    exit 1
fi


echo "Applying skeleton settings \n"

apply_settings() {
    local namespace=$1
    local file=$2

    while IFS='=' read -r key value; do
        # Ignore empty lines or comments
        [[ -z "$key" || "$key" =~ ^# ]] && continue

        echo "Setting $namespace $key to $value..."
        adb shell settings put "$namespace" "$key" "$value"
    done < "$file"
}

# Apply settings from skeleton
apply_settings global skeleton/settingsGlobal
apply_settings secure skeleton/settingsSecure
apply_settings system skeleton/settingsSystem


# Apply device name
echo "Setting global device_name to $DEVICENAME..."
adb shell settings put global device_name "$DEVICENAME"

echo "Setting secure bluetooth_name to $DEVICENAME..."
adb shell settings put secure bluetooth_name "$DEVICENAME"

TASKS_DIR="skeleton/adminTasksScripts"

# Loop through each `.sh` script in numerical order
for script in $(ls "$TASKS_DIR"/*.sh | sort); do
    echo "Running $script..."
    bash "$script" || { echo "Error occurred in $script. Exiting."; exit 1; }
done

echo "All tasks completed!"