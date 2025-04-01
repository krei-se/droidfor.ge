#!/bin/bash

functions/adbChecks.sh
if [ $? -ne 0 ]; then
    echo "One ore more ADB checks failed"
    exit 1
fi

source ./functions/getUserIdFromPackageName.sh

# Needed in any case
PACKAGES=("com.termux" "com.termux.boot" "com.topjohnwu.magisk")

# Add OpenVPN, DAVx5 and jtx Board if you want or others like this:
PACKAGES+=("de.blinkt.openvpn" "at.bitfire.davdroid" "at.techbee.jtx")

# Stores
    PACKAGES+=("com.aurora.store" "org.fdroid.fdroid")

# Media
    PACKAGES+=("ch.blinkenlights.android.vanilla" "org.schabi.newpipe" "org.videolan.vlc" )

# Social
    PACKAGES+=("org.quantumbadger.redreader" "nl.viter.glider")

# "Smart" Home
    PACKAGES+=("org.gateshipone.malp")

for PACKAGE in "${PACKAGES[@]}"; do



        else
            echo "$PACKAGE is NOT installed."
        fi

done