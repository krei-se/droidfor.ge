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
    echo "Usage: $0 <devicename.domain.tld> <user@domain.tld> <userhome-folder=~>"
    exit 1
fi

DEVICENAMEFQDN=$1
USERACCOUNT=$2
USERHOME=$3

USERNAME=$(echo "$USERACCOUNT" | cut -d'@' -f1)


# Check if DEVICENAMEFQDN has at least two dots (indicating a valid FQDN)
DOT_COUNT=$(echo "$DEVICENAMEFQDN" | awk -F'.' '{print NF-1}')

if [ "$DOT_COUNT" -lt 2 ]; then
    echo "Error: The provided DEVICENAMEFQDN '$DEVICENAMEFQDN' does not contain at least two dots (hostname and domain are required)."
    exit 1
fi

DROIDFORGEAUTOPROVISIONDEVICENAMEFQDN=$DEVICENAMEFQDN
export DROIDFORGEAUTOPROVISIONDEVICENAMEFQDN

DEVICENAME=$(echo "$DEVICENAMEFQDN" | cut -d'.' -f1)
DROIDFORGEAUTOPROVISIONDEVICENAME=$DEVICENAME
export DROIDFORGEAUTOPROVISIONDEVICENAME

DOMAIN=$(echo "$DEVICENAMEFQDN" | cut -d'.' -f2-)

DROIDFORGEAUTOPROVISIONDOMAIN=$DOMAIN
export DROIDFORGEAUTOPROVISIONDOMAIN

echo -e "Device name to be userProvisioned is \033[0;34m$DEVICENAMEFQDN\033[0m - derived Host \033[0;34m$DEVICENAME\033[0m in Domain \033[0;31m$DOMAIN\033[0m"

echo -e "User Account to be setup is \033[0;32m$USERACCOUNT\033[0m - derived Name \033[0;32m$USERNAME\033[0m"

read -p "Are these settings correct? (y/n): " choice
    case "$choice" in
        y|Y )
            echo "Continuing domainProvisioning..."
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



echo -e "Checking if the device is rooted ... \n"

./checkAdbHasRoot.sh
if [ $? -ne 0 ]; then
    echo "🍨Device is not running in adb rooted mode! Install and setup Magisk. Exiting..."
    exit 1
fi


TASKS_DIR="skeleton/userTasksScripts"

# Loop through each `.sh` script in numerical order
for script in $(ls "$TASKS_DIR"/*.sh | sort); do
    echo "Running $script..."
    bash "$script" || { echo "Error occurred in $script. Exiting."; exit 1; }
done

echo "All tasks completed!"