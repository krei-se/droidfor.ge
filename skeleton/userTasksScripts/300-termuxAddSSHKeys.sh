#!/bin/bash

functions/adbChecks.sh
if [ $? -ne 0 ]; then
    echo "One ore more ADB checks failed"
    exit 1
fi

source ./functions/getUserIdFromPackageName.sh

adb shell monkey -p com.termux -c android.intent.category.LAUNCHER 1


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

if [[ "$DROIDFORGEAUTOPROVISIONDEVICESSHRUNNING" == true ]]; then


        package="com.termux"
        user_id=$(getUserIdFromPackageName "$package")
        uid=$(getUidFromPackageName "$package")


        echo "User for $package: $user_id"
        echo "UID for $package: $uid"


    if [ -f "$DROIDFORGEAUTOPROVISIONUSERHOME/.ssh/id_ed25519.pub" ]; then

        SSH_KEY=$(cat "$DROIDFORGEAUTOPROVISIONUSERHOME/.ssh/id_ed25519.pub")
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
    if [ -f "$DROIDFORGEAUTOPROVISIONUSERHOME/.ssh/id_ed25519_android.pub" ]; then

        SSH_KEY=$(cat "$DROIDFORGEAUTOPROVISIONUSERHOME/.ssh/id_ed25519_android.pub")
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