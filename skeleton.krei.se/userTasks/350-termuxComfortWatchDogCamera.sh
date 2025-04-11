#!/bin/bash

functions/adbChecks.sh
if [ $? -ne 0 ]; then
    echo "One ore more ADB checks failed"
    exit 1
fi

source ./functions/getUserIdFromPackageName.sh

INSTALLCAMERAADDON=false

read -p "Do you want to install the comfort Addon to automatically send Camera Photos and Videos to the users home? (y/n): " choice
    case "$choice" in
        y|Y )
            echo "Installing Camera Addon"
            INSTALLCAMERAADDON=true
            ;;
        n|N )
            echo "Not installing Camera Addon."
            ;;
        * )
            echo "Invalid input. Continuing userProvision"
            exit 0
            ;;
    esac

if [[ $INSTALLCAMERAADDON -eq true ]]; then

    package="com.termux"
    user_id=$(getUserIdFromPackageName "$package")
    uid=$(getUidFromPackageName "$package")


    echo "User for $package: $user_id"
    echo "UID for $package: $uid"

    echo "-------------"
    echo "Installing Camera Addon. This will create a set of ssh-keys on the device, then add them in the users home .ssh/authorized_keys"
    echo "These keys can only save new files / photos to ~/Pictures/Camera via scp, nothing else."
    echo "-------------"

    USERSSHKEYFILE="$USERHOME/.ssh/id_ed25519"

    # make sure local user has Camera subfolder
    if [[ ! -d "$USERHOME/Pictures/Camera" ]]; then
        mkdir -p "$USERHOME/Pictures/Camera"

        # not tested! ;)
        chown --reference=$USERHOME "$USERHOME/Pictures/Camera"

    fi

    # fix permissions for LDAPUsers

    # make sure user has /sdcard/DCIM/Camera on phone
    # this is somewhat easy as its root:everybody
    adb shell "mkdir -p /sdcard/DCIM/Camera"




    # if created use the _android key
    if [ -f "$USERHOME/.ssh/id_ed25519_android" ]; then
        USERSSHKEYFILE="$USERHOME/.ssh/id_ed25519_android"
    fi

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


    # create the key remotely on the device
    ssh -i "$USERSSHKEYFILE" $user_id@$FIXEDIP_ADDRESS -p 8022 ssh-keygen -t ed25519 -f .ssh/id_ed25519_camerawatchdog -N "''"
    # then save it to a var
    CAMERAWATCHDOGKEY=$(ssh -i "$USERSSHKEYFILE" $user_id@$FIXEDIP_ADDRESS -p 8022 cat .ssh/id_ed25519_camerawatchdog.pub)

    # finally add it to the users authorized_keys
    echo -e "command=\"scp -v -t $USERHOME/Pictures/Camera\",no-pty,no-X11-forwarding $CAMERAWATCHDOGKEY" >> $USERHOME/.ssh/authorized_keys

    echo "-------------"
    echo "Keys installed to users home .ssh/authorized_keys"
    echo "please doublecheck the contents:"
    echo "-------------"

    cat $USERHOME/.ssh/authorized_keys

    # customizing the users cameraWatchdog.sh
    ssh -i "$USERSSHKEYFILE" $user_id@$FIXEDIP_ADDRESS -p 8022 -o SendEnv=USERNAME "sed -i 's/^USER=.*/USER=$USERNAME/' cameraWatchdog.sh"
    ssh -i "$USERSSHKEYFILE" $user_id@$FIXEDIP_ADDRESS -p 8022 -o SendEnv=DOMAIN "sed -i 's/^DOMAIN=.*/DOMAIN=$DOMAIN/' cameraWatchdog.sh"

    # make sure its executable, you never know
    ssh -i "$USERSSHKEYFILE" $user_id@$FIXEDIP_ADDRESS -p 8022 "chmod +x ~/cameraWatchdog.sh"

    # make sure it's symlinked to boot
    ssh -i "$USERSSHKEYFILE" $user_id@$FIXEDIP_ADDRESS -p 8022 "ln -sf ~/cameraWatchdog.sh .termux/boot/cameraWatchdog.sh"

    # start it remotely
    ssh -i "$USERSSHKEYFILE" $user_id@$FIXEDIP_ADDRESS -p 8022 ".termux/boot/cameraWatchdog.sh &" &

fi
