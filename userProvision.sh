#!/bin/bash

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


if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: $0 <devicename.domain.tld> <user@domain.tld> <multiuserid=0>"
    exit 1
fi

DEVICENAMEFQDN=$1
USERACCOUNT=$2
MULTIUSERID=$3

if [[ -z "$3" ]]; then
    MULTIUSERID=0
fi

USERNAME=$(echo "$USERACCOUNT" | cut -d'@' -f1)
export USERNAME

# Check if DEVICENAMEFQDN has at least two dots (indicating a valid FQDN)
DOT_COUNT=$(echo "$DEVICENAMEFQDN" | awk -F'.' '{print NF-1}')

if [ "$DOT_COUNT" -lt 2 ]; then
    echo "Error: The provided DEVICENAMEFQDN '$DEVICENAMEFQDN' does not contain at least two dots (hostname and domain are required)."
    exit 1
fi

export DEVICENAMEFQDN
export USERACCOUNT
export MULTIUSERID

DEVICENAME=$(echo "$DEVICENAMEFQDN" | cut -d'.' -f1)

export DEVICENAME

DOMAIN=$(echo "$DEVICENAMEFQDN" | cut -d'.' -f2-)

export DOMAIN

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

functions/checkAdbHasRoot.sh
if [ $? -ne 0 ]; then
    echo "🍨Device is not running in adb rooted mode! Install and setup Magisk. Exiting..."
    exit 1
fi


# Try to lookup the user via LDAP or use ~ as USERHOME

eval "$(functions/ldapLookup.sh $USERACCOUNT)"

echo "LDAP User UID: $LDAPUID"
echo "LDAP User GID: $LDAPGID"
echo "LDAP Primary Group: $LDAPGROUP_NAME"
echo "LDAP User UID: $LDAPHOME"

if [ -n "$LDAPHOME" ]; then
    USERHOME=$LDAPHOME
else
    USERHOME=~
fi

export USERHOME

# create device folder in $USERHOME
mkdir -p $USERHOME/.android/devices/$DEVICENAMEFQDN


TASKS_DIR="skeleton/userTasksScripts"

# Loop through each `.sh` script in numerical order
for script in $(ls "$TASKS_DIR"/*.sh | sort); do
    echo "Running $script..."
    bash "$script" || { echo "Error occurred in $script. Exiting."; exit 1; }
done

echo "All tasks completed!"

# fix permissions of $LDAPHOME/.android/devices/$DEVICENAMEFQDN
if [[ -n "$LDAPHOME" && -n "$LDAPUID" && -n "$LDAPGROUPNAME" ]]; then

    echo "setting permissions";
    chown -R $LDAPUID:$LDAPGROUP_NAME $LDAPHOME/.android/devices/$DEVICENAMEFQDN

fi


