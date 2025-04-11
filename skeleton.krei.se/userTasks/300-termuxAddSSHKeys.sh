#!/bin/bash

functions/adbChecks.sh
if [ $? -ne 0 ]; then
    echo "One ore more ADB checks failed"
    exit 1
fi

source ./functions/getUserIdFromPackageName.sh

adb shell monkey -p com.termux -c android.intent.category.LAUNCHER 1


# Check SSH Port

        DEVICESSHRUNNING=false
        export DEVICESSHRUNNING

        FOUNDIP=false
        FIXEDIP_ADDRESS=""

        while [[ $FOUNDIP == false ]]; do
            # Resolve the current IP from the FQDN
            FIXEDIP_ADDRESS=$(dig +short $DEVICENAMEFQDN | head -n 1)

            # Ping the resolved IP to see if it's reachable
            ping -c 1 -W 2 $FIXEDIP_ADDRESS &> /dev/null

            if [[ $? -eq 0 ]]; then
                # If ping succeeds, print the IP address
                echo "Device is reachable at IP: $FIXEDIP_ADDRESS"
                FOUNDIP=true
            else
                echo "Failed to reach device at IP: $FIXEDIP_ADDRESS, trying again..."
                sleep 2
            fi
        done

        echo "Device likely ... found at IP: $FIXEDIP_ADDRESS"

        export FIXEDIP_ADDRESS

        # test sshd port 8022 open
        nc -zv -w 5 "${FIXEDIP_ADDRESS}" 8022 &> /dev/null

        if [[ $? -eq 0 ]]; then
            echo "✅ sshd port 8022 is open on the device"
            DEVICESSHRUNNING=true
            adb shell input keyevent 3

        else
            echo "❌ sshd port is closed"
            read -n 1 -s -r -p "SSHD Port is closed or the hostname was not found yet - press any key to continue..."
            
        fi

if [[ "$DEVICESSHRUNNING" == true ]]; then


        package="com.termux"
        user_id=$(getUserIdFromPackageName "$package")
        uid=$(getUidFromPackageName "$package")


        echo "User for $package: $user_id"
        echo "UID for $package: $uid"


    if [ -f "$USERHOME/.ssh/id_ed25519.pub" ]; then

        SSH_KEY=$(cat "$USERHOME/.ssh/id_ed25519.pub")
        adb shell "mkdir -p /data/data/com.termux/files/home/.ssh"
        
        # Add the public key to the authorized_keys file
        adb shell "echo '$SSH_KEY' >> /data/data/com.termux/files/home/.ssh/authorized_keys"
        
        # Set correct permissions for the .ssh directory and authorized_keys
        adb shell "chmod 700 /data/data/com.termux/files/home/.ssh"
        adb shell "chmod 600 /data/data/com.termux/files/home/.ssh/authorized_keys"
        adb shell "chown -R $user_id:$user_id /data/data/com.termux/files/home/.ssh"
        adb shell "find /data/data/com.termux/files/home/.ssh -exec restorecon {} \;"



    fi

    # copy a second key ending in _android - useful for unlocked ssh keys for syncing
    if [ -f "$USERHOME/.ssh/id_ed25519_android.pub" ]; then

        SSH_KEY=$(cat "$USERHOME/.ssh/id_ed25519_android.pub")
        adb shell "mkdir -p /data/data/com.termux/files/home/.ssh"
        
        # Add the public key to the authorized_keys file
        adb shell "echo '$SSH_KEY' >> /data/data/com.termux/files/home/.ssh/authorized_keys"
        
        # Set correct permissions for the .ssh directory and authorized_keys
        adb shell "chmod 700 /data/data/com.termux/files/home/.ssh"
        adb shell "chmod 600 /data/data/com.termux/files/home/.ssh/authorized_keys"
        adb shell "chown -R $user_id:$user_id /data/data/com.termux/files/home/.ssh"
        adb shell "find /data/data/com.termux/files/home/.ssh -exec restorecon {} \;"

    fi

fi