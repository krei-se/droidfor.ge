#!/bin/bash

#################################################################
#	IMPORTANT: UPDATE TO LATEST VERSIONS FROM FDROID	#
#################################################################

mkdir -p initialApps

# Grab latest Termux, Termux Boot and Magisk App
curl https://f-droid.org/repo/com.termux.boot_1000.apk -o initialApps/com.termux.boot.apk
curl https://f-droid.org/repo/com.termux_1020.apk -o initialApps/com.termux.apk
curl https://f-droid.org/repo/com.topjohnwu.magisk_28100.apk -o initialApps/com.topjohnwu.magisk.apk

