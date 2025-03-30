#!/bin/bash


# Loop through all folders in ./devices
for deviceFolder in ./devices/*/; do

    deviceFolder="${deviceFolder%/}"
    device="${deviceFolder##*/}"

    # Try to ping the device to check if it's reachable
    if ! ping -c 1 -W 5 "$device" &> /dev/null; then
        echo "Device $device is unreachable. Skipping..."
        continue  # Skip this device and move to the next
    fi


    adb connect $device:5555

    mkdir -p $deviceFolder/apks
    mkdir -p $deviceFolder/appData

    echo "Applist for $device:"



    apps=()

    if [[ -f "$deviceFolder/applist" ]]; then

        while IFS= read -r line; do

        # skips empty lines and comments
        if [[ -n "$line" && ! "$line" =~ ^# ]]; then
            apps+=("$line")
        fi
        done < "$deviceFolder/applist"

        echo "${apps[@]}"

        for app in "${apps[@]}"; do

            # backup apk
            echo $app

            packageLine=$(adb -s $device:5555 shell "pm list packages -f -3 | grep $app" )

            apkPath=$(echo "$packageLine" | sed -E 's/package:(\/data\/app\/[^/]+\/[^/]+)\/base.apk=.*/\1/')


            echo $packageLine
            echo $apkPath

            if [ -n "$apkPath" ]; then

              # Pull APK if path is valid
                if ! adb -s "$device:5555" pull "$apkPath/base.apk" "$deviceFolder/apks/$app.apk"; then
                    echo "Failed to pull APK for $app"
                    # skips at for app level
                    continue
                fi

                # keep 3 backups per app
                mkdir -p "$deviceFolder/appData/$app"
                mkdir -p "$deviceFolder/appData/$app.oneday"
                mkdir -p "$deviceFolder/appData/$app.twodays"

                # remove oldest backup.          remove files                               remove subfolders
                rm -rf $deviceFolder/appData/$app.twodays/* $deviceFolder/appData/$app.twodays/.*

                # not really needed
                #rmdir $deviceFolder/appData/$app.twodays/

                # FILO
                mv $deviceFolder/appData/$app.oneday  $deviceFolder/appData/$app.twodays
                mv $deviceFolder/appData/$app         $deviceFolder/appData/$app.oneday

                mkdir -p $deviceFolder/appData/$app

                # cool hack to exclude caches
                adb -s "$device:5555" shell "find /data/data/$app -type f ! -path '*cache*' ! -path '*no_backup*'" |
                while read -r file; do
                # Pull each file individually (avoiding cache subfolder)
                    adb -s "$device:5555" pull "$file" "$deviceFolder/appData/$app/$(basename $file)"
                done
                #adb -s "$device:5555" pull "$apkPath/base.apk" "$deviceFolder/apks/$app.apk"


                #adb -s "$device:5555" pull "/data/data/$app" "$deviceFolder/appData/$app"
                #adb -s "$device:5555" backup -f $deviceFolder/appData/$app.ab -noapk $app

            fi

            # backup only data

        done
    fi
done
