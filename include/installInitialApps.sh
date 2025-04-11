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
        package_name=${apk%.apk}
        package_name="${package_name##*/}"  # Ensure it's just the package name without the path
        
                                                # make sure to use -o when doing grep -E
        INSTALLED=$(adb shell pm list packages -3 | grep -E "\b${package_name}$" -o)
        #echo $INSTALLED
        if [ -z "$INSTALLED" ]; then
            echo "Installing $apk ..."                          
            adb install "$apk"
        else
            echo $package_name "already installed, skipping."
        fi
    fi
done

echo "All Initial Apps installed!"
