#!/bin/bash

mkdir -p initialApps

# If you get the error that the app is not compatible ABI, add :[int] to the package name.
# It will get all versions from the api and take the one with this integer ending.
# https://f-droid.org/de/packages/org.videolan.vlc/ f.e. will give you x86 with :8 and armv8 with :6

# Needed in any case
PACKAGES=("com.termux" "com.termux.boot" "com.topjohnwu.magisk")

# Add OpenVPN, DAVx5 and jtx Board if you want or others like this:
PACKAGES+=("de.blinkt.openvpn" "at.bitfire.davdroid" "at.techbee.jtx")

# Stores
    PACKAGES+=("com.aurora.store" "org.fdroid.fdroid")

# Media
    PACKAGES+=("ch.blinkenlights.android.vanilla" "org.schabi.newpipe" "org.videolan.vlc:6" )

# Social
    PACKAGES+=("org.quantumbadger.redreader" "nl.viter.glider")

# "Smart" Home
    PACKAGES+=("org.gateshipone.malp")

source ./functions/fetchFdroidApk.sh

for PACKAGE in "${PACKAGES[@]}"; do
    fetch_fdroid_apk "$PACKAGE"
done

