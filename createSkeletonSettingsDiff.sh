#!/bin/bash

# Check if the file exists and is not empty
if [ ! -s "skeleton/vanilla/settingsGlobal" ] || [ ! -s "skeleton/vanilla/settingsSecure" ] || [ ! -s "skeleton/vanilla/settingsSystem" ]; then
  echo "Error: Files skeleton/vanilla/settings* does not exist or is empty. Run ./grabVanillaSkeletonSettings.sh before diffing the skeleton."
  exit 1
fi

./checkUserHasAdbAndRsyncLocally.sh
if [ $? -ne 0 ]; then
    echo "Please install adb and rsync. apt install android-tools-adb rsync Exiting..."
    exit 1
fi

./checkAdbDeviceConnection.sh
if [ $? -ne 0 ]; then
    echo "🩻 Skeleton donor device not connected! Exiting..."
    exit 1
fi

./checkAdbHasRoot.sh
if [ $? -ne 0 ]; then
    echo "🩻 Skeleton donor device is not running in adb rooted mode! Install and setup Magisk. Exiting..."
    exit 1
fi

echo ""


adb shell settings list global > /tmp/settingsGlobal
adb shell settings list system > /tmp/settingsSystem
adb shell settings list secure > /tmp/settingsSecure


diff --new-line-format="%L" --old-line-format="" --unchanged-line-format="" skeleton/vanilla/settingsGlobal /tmp/settingsGlobal > skeleton/settingsGlobal
diff --new-line-format="%L" --old-line-format="" --unchanged-line-format="" skeleton/vanilla/settingsSecure /tmp/settingsSecure > skeleton/settingsSecure
diff --new-line-format="%L" --old-line-format="" --unchanged-line-format="" skeleton/vanilla/settingsSystem /tmp/settingsSystem > skeleton/settingsSystem

# Remove settings that will change during setup usually like brightness and chargetime
#   doze/sleep state
    sed -i '/^restart_nap_after_start/d' skeleton/settingsSecure
    #sed -i '/^night_display_activated/d' skeleton/settingsSecure
    sed -i '/^night_display_last_activated_time/d' skeleton/settingsSecure

#   Screen Brightness
    sed -i '/^screen_brightness/d' skeleton/settingsSystem

# Remove changed bluetooth and device name
    sed -i '/^device_name/d' skeleton/settingsGlobal
    sed -i '/^bluetooth_name/d' skeleton/settingsSecure



echo "Changed in Settings Global: "
echo "--------------------------- "

cat skeleton/settingsGlobal
echo ""

echo "Changed in Settings Secure: "
echo "--------------------------- "
cat skeleton/settingsSecure
echo ""

echo "Changed in Settings System: "
echo "--------------------------- "
cat skeleton/settingsSystem
echo ""






echo "Settings diff saved to skeleton/settings"

