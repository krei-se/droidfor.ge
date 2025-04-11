#!/bin/bash

# Run adb devices command and capture output
mapfile -t adb_output < <(adb devices -l)

lineCounter=0

for line in "${adb_output[@]}"; do
    if [[ "$line" == "List of devices attached" ]]; then
        deviceLineNumber=$lineCounter
        break
    fi
    ((lineCounter++))
done

# Check if the header line was found
if [[ $deviceLineNumber -ge 0 ]]; then
    # Collect all lines after the header that are not empty
    adbDevices=()
    adbDevicesTypes=()
    adbDevicesProperties=()
    for (( j = deviceLineNumber + 1; j < ${#adb_output[@]}; j++ )); do
        line="${adb_output[$j]}"
        if [[ -n "$line" ]]; then
            parts=($line)
            adbDevices+=("${parts[0]}")
            adbDevicesTypes+=("${parts[1]}")
            adbDevicesProperties+=("${parts[-3]}")
        fi
    done
fi

for dev in "${adbDevices[@]}"; do
    echo "Found device: $dev"
done

if [[ ${#adbDevices[@]} -eq 0 ]]; then

    DF_ADB_DEVICESERIAL=""
    whiptail \
        --title "No Android device found via ADB" \
        --msgbox "It seems there are no android devices connected via ADB. This will only softfail, but will totally annoy you because we check for this very often. Please make sure to connect a device!" \
        10 $WT_WIDTH

else

    while [[ -z "$DF_MACHINE_ADBID" ]]; do

        if [[ ${#adbDevices[@]} -eq 1 ]]; then

            DF_MACHINE_ADBID=${adbDevices[0]}

        fi

        if [[ -z "$DF_MACHINE_ADBID" && ${#adbDevices[@]} -gt 1 ]]; then

            WT_SELECTS=()

            # would work, but we need index anyway
            # for device in "${adbDevices[@]}"; do
            for ((i = 0; i < ${#adbDevices[@]}; i++)); do
                WT_SELECTS+=("${adbDevices[$i]}")

                WT_SELECTS+=("${adbDevicesProperties[$i]}")
            done

            WT_SELECTS+=("" "")
            WT_SELECTS+=("_HaveThemBlink" "I have no idea, can't you have them blink?")
            

            #echo "${WT_SELECTS[@]}"

            GUI_ADBDEVICE_CHOICE=$(whiptail --title "Multiple ADB devices found" --menu "Please select your primary ADB device" $WT_HEIGHT $WT_WIDTH $WT_MENUHEIGHT \
            "${WT_SELECTS[@]}" \
            3>&1 1>&2 2>&3
            )

            GUI_ADBDEVICE_EXIT_STATUS=$?

            #echo $GUI_ADBDEVICE_EXIT_STATUS
            # lets make them blink

            if [[ "$GUI_ADBDEVICE_EXIT_STATUS" -eq 0 ]]; then

                if [[ "$GUI_ADBDEVICE_CHOICE" == "_HaveThemBlink" ]]; then

                    for ((i = 0; i < ${#adbDevices[@]}; i++)); do
                        echo "Letting ${adbDevices[$i]} sleep . . ."
                        adb -s ${adbDevices[$i]} shell input keyevent KEYCODE_SLEEP
                        sleep 1
                        echo "Waking ${adbDevices[$i]} up . . . . ."
                        adb -s ${adbDevices[$i]} shell input keyevent KEYCODE_WAKEUP
                        sleep 1
                        echo "Letting ${adbDevices[$i]} sleep again . . ."
                        adb -s ${adbDevices[$i]} shell input keyevent KEYCODE_SLEEP
                        sleep 0
                    done

                else

                        DF_MACHINE_ADBID=$GUI_ADBDEVICE_CHOICE

                fi

            fi

            if [[ "$GUI_ADBDEVICE_EXIT_STATUS" -eq 1 ]]; then
                exit 1
            fi

        fi

    done

fi

export DF_MACHINE_ADBID

return 0