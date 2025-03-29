#!/bin/bash


functions/checkAdbDeviceConnection.sh
if [ $? -ne 0 ]; then
    echo "Android device not connected! Exiting..."
    exit 1
fi
echo ""

# Directory containing APKs
APK_DIR="initialApps"

# Check if directory exists
if [ ! -d "$APK_DIR" ]; then
    echo "Directory $APK_DIR does not exist!"
    exit 1
fi

# Find all APK files and install them
for apk in "$APK_DIR"/*.apk; do
    if [ -f "$apk" ]; then
        echo "Installing $apk ..."
        adb install "$apk"
    fi
done

echo "All Initial Apps installed!"
