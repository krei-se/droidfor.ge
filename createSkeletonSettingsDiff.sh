#!/bin/bash

# Check if the file exists and is not empty
if [ ! -s "skeleton/vanilla/settingsGlobal" ] || [ ! -s "skeleton/vanilla/settingsSecure" ] || [ ! -s "skeleton/vanilla/settingsSystem" ]; then
  echo "Error: Files skeleton/vanilla/settings* does not exist or is empty. Run ./grabVanillaSkeletonSettings.sh before diffing the skeleton."
  exit 1
fi

functions/checkUserHasAdbAndRsyncLocally.sh
if [ $? -ne 0 ]; then
    echo "Please install adb and rsync. apt install android-tools-adb rsync Exiting..."
    exit 1
fi

functions/checkAdbDeviceConnection.sh
if [ $? -ne 0 ]; then
    echo "🩻 Skeleton donor device not connected! Exiting..."
    exit 1
fi

functions/checkAdbHasRoot.sh
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

# Remove time to full
    sed -i '/^time_to_full_millis/d' skeleton/settingsGlobal

# Other stuff i noticed

    sed -i '/^network_watchlist_last_report_time/d' skeleton/settingsGlobal


# Remove any attempt to bother the user with custom ringtones:

    sed -i '/sound=content:/d' skeleton/settingsGlobal
    sed -i '/sound=content:/d' skeleton/settingsSecure
    sed -i '/sound=content:/d' skeleton/settingsSystem
    

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

read -p "Do you want to grab the AOSP Keyboard settings (user profile data)? (y/n): " choice
    case "$choice" in
        y|Y )
            echo "saving com.android.inputmethod.latin_preferences.xml to skeleton/com.android.inputmethod.latin_preferences.xml"
            adb pull /data/user_de/0/com.android.inputmethod.latin/shared_prefs/com.android.inputmethod.latin_preferences.xml skeleton/com.android.inputmethod.latin_preferences.xml
            ;;
        n|N )
            echo "Not saving the inputmethod xml."
            ;;
        * )
            echo "Invalid input."
            ;;
    esac

echo "Continuing!"


read -p "Do you want to grab the Lineage Navbar settings (user profile data)? (y/n): " choice
    case "$choice" in
        y|Y )
            echo "saving com.android.inputmethod.latin_preferences.xml to skeleton/com.android.inputmethod.latin_preferences.xml"
            adb pull /data/user_de/0/com.android.inputmethod.latin/shared_prefs/com.android.inputmethod.latin_preferences.xml skeleton/com.android.inputmethod.latin_preferences.xml
            ;;
        n|N )
            echo "Not saving the inputmethod xml."
            ;;
        * )
            echo "Invalid input."
            ;;
    esac

echo "Continuing!"

