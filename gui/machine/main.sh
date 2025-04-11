#!/bin/bash

if [[ -z DF_RANMAIN ]]; then
    echo "please don't run these scripts separately, use ./droidfor.ge.sh in the projects root"
    exit 1
fi


if [[ -n "$DF_MACHINE_FQDN" ]]; then
    WT_TITLE="🤖 Droidfor.ge for $DF_MACHINE_FQDN"
else
    WT_TITLE="Welcome to 🤖 Droidfor.ge"
fi

export WT_TITLE

source ./include/functions/configSummary.sh

#echo -e "$DF_CONFIG_SUMMARY"

#    1> success.log   2> error.log
# redirect stderr to stdout: 3>&1 1>&2 2>&3
# 3>$1 means take stdout to 3,
# 1>$2 means take stderr to stdout
# 2>$3 means take 3 now back to stderr (essentially switch stdout and stderr)

GUI_MACHINE_MAIN_CHOICES=("SelectDevice" "Select ADB Device")
GUI_MACHINE_MAIN_CHOICES+=("" "")
GUI_MACHINE_MAIN_CHOICES+=("SetName" "Set the Machines Name")

GUI_MACHINE_MAIN_CHOICES+=("" "")



GUI_MACHINE_MAIN_CHOICES+=("<--" "Back to Main")

#echo ${GUI_DOMAIN_MAIN_CHOICES[@]}

GUI_MACHINE_MAIN_CHOICE=$(whiptail --title "$WT_TITLE" --menu "$DF_CONFIG_SUMMARY" $WT_HEIGHT $WT_WIDTH $WT_MENUHEIGHT \
    "${GUI_MACHINE_MAIN_CHOICES[@]}" \
    3>&1 1>&2 2>&3
    )

EXIT_STATUS=$?

if [[ "$EXIT_STATUS" -eq 0 ]]; then

    if [[ "$GUI_MACHINE_MAIN_CHOICE" == "SelectDevice" ]]; then
        DF_MACHINE_ADBID=""
        source ./gui/adb/selectDevice.sh
    fi

    if [[ "$GUI_MACHINE_MAIN_CHOICE" == "SetName" ]]; then
        
        source ./gui/machine/setName.sh
    fi


    if [[ "$GUI_MACHINE_MAIN_CHOICE" != "<--" ]]; then
        source ./gui/machine/main.sh
    fi

    if [[ "$GUI_MACHINE_MAIN_CHOICE" == "<--" ]]; then
        return 0
    fi

    return 0

fi

if [[ "$EXIT_STATUS" -eq 1 ]]; then
    return 0
fi
