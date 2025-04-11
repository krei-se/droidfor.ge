#!/bin/bash

if [[ -z DF_RANMAIN ]]; then
    echo "please don't run these scripts separately, use ./droidfor.ge.sh in the projects root"
    exit 1
fi


if [[ -n "$DF_DOMAIN_FQDN" ]]; then
    WT_TITLE="🤖 Droidfor.ge for $DF_DOMAIN_FQDN"
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

GUI_DOMAIN_MAIN_CHOICES=("Autodetect" "Autodetect Domain and Services" \
"Manual" "Manually set the FDQN")

GUI_DOMAIN_MAIN_CHOICES+=("" "")
GUI_DOMAIN_MAIN_CHOICES+=("" "🤵 Services")
GUI_DOMAIN_MAIN_CHOICES+=("Services" "Autodetect Services within your domain")

#if [[ "$DF_DOMAIN_HAS_LDAP" -eq 0 ]]; then
    GUI_DOMAIN_MAIN_CHOICES+=("HowtoRecords" "Are services missing or wrong? -> help!!")
#fi

#GUI_DOMAIN_MAIN_CHOICES+=("Manual" "Manually set the FDQN")
GUI_DOMAIN_MAIN_CHOICES+=("" "")
GUI_DOMAIN_MAIN_CHOICES+=("" "🩻 Domain-Skeleton")

if [[ -n "$DF_DOMAIN_FQDN" && ! -d "skeleton.$DF_DOMAIN_FQDN" ]]; then
    GUI_DOMAIN_MAIN_CHOICES+=("CreateSkeleton" "Create Domain-Skeleton from Krei.se-Template")
fi


if [[ -n "$DF_DOMAIN_FQDN" && -d "skeleton.$DF_DOMAIN_FQDN" ]]; then
    GUI_DOMAIN_MAIN_CHOICES+=("UpdateSkeleton" "Update Domain-Skeleton from Krei.se-Template")
fi

GUI_DOMAIN_MAIN_CHOICES+=("" "")
GUI_DOMAIN_MAIN_CHOICES+=("" "⚙️ Settings and ⌨️ Input")

if [[ -n "$DF_DOMAIN_FQDN" && ! -f "skeleton.$DF_DOMAIN_FQDN/vanillaSettingsDump/settingsGlobal" ]]; then
    GUI_DOMAIN_MAIN_CHOICES+=("DumpVanilla" "Dump Vanilla-Settings from a virgin device")
fi
if [[ -n "$DF_DOMAIN_FQDN" && -f "skeleton.$DF_DOMAIN_FQDN/vanillaSettingsDump/settingsGlobal" ]]; then
    GUI_DOMAIN_MAIN_CHOICES+=("UpdateVanilla" "Overwrite Vanilla-Settings from a virgin device")
    GUI_DOMAIN_MAIN_CHOICES+=("SkeletonSettings" "Create the Settings-Diff for the Skeleton")
    
fi

GUI_DOMAIN_MAIN_CHOICES+=("" "")
GUI_DOMAIN_MAIN_CHOICES+=("" "🔐 OpenVPN Autoprovision")

GUI_DOMAIN_MAIN_CHOICES+=("PKIPath" "Change the path to the EasyRSA-PKI for OpenVPN Keys/Certs")

GUI_DOMAIN_MAIN_CHOICES+=("" "")
GUI_DOMAIN_MAIN_CHOICES+=("" "🌳 LDAP Settings")
GUI_DOMAIN_MAIN_CHOICES+=("LDAPSettings" "Change URI, baseDN or lookupDN")


GUI_DOMAIN_MAIN_CHOICES+=("" "")
GUI_DOMAIN_MAIN_CHOICES+=("" "💾 Save/Load Config")
GUI_DOMAIN_MAIN_CHOICES+=("LoadConfig" "Load skeleton.$DF_DOMAIN_FQDN/config.ini")
GUI_DOMAIN_MAIN_CHOICES+=("SaveConfig" "Save skeleton.$DF_DOMAIN_FQDN/config.ini")


GUI_DOMAIN_MAIN_CHOICES+=("" "")
GUI_DOMAIN_MAIN_CHOICES+=("<--" "Back to Main")

#echo ${GUI_DOMAIN_MAIN_CHOICES[@]}

GUI_DOMAIN_MAIN_CHOICE=$(whiptail --title "$WT_TITLE" --menu "$DF_CONFIG_SUMMARY" $WT_HEIGHT $WT_WIDTH $WT_MENUHEIGHT \
    "${GUI_DOMAIN_MAIN_CHOICES[@]}" \
    3>&1 1>&2 2>&3
    )

EXIT_STATUS=$?

if [[ "$EXIT_STATUS" -eq 0 ]]; then

    if [[ "$GUI_DOMAIN_MAIN_CHOICE" == "Autodetect" ]]; then
        source ./gui/domain/autodetect.sh
    fi

    if [[ "$GUI_DOMAIN_MAIN_CHOICE" == "Manual" ]]; then
        source ./gui/domain/manual.sh
    fi

    if [[ "$GUI_DOMAIN_MAIN_CHOICE" == "Services" ]]; then
        source ./gui/domain/autodetectServices.sh
    fi

    if [[ "$GUI_DOMAIN_MAIN_CHOICE" == "HowtoRecords" ]]; then
        source ./gui/domain/howtoRecords.sh
    fi

    if [[ "$GUI_DOMAIN_MAIN_CHOICE" == "CreateSkeleton" ]]; then
        source ./gui/domain/createSkeleton.sh
    fi

    if [[ "$GUI_DOMAIN_MAIN_CHOICE" == "UpdateSkeleton" ]]; then
        source ./gui/domain/updateSkeleton.sh
    fi

    if [[ "$GUI_DOMAIN_MAIN_CHOICE" == "DumpVanilla" ]]; then
        source ./gui/domain/dumpVanilla.sh
    fi

    if [[ "$GUI_DOMAIN_MAIN_CHOICE" == "UpdateVanilla" ]]; then
        source ./gui/domain/updateVanilla.sh
    fi

    if [[ "$GUI_DOMAIN_MAIN_CHOICE" == "SkeletonSettings" ]]; then
        source ./gui/domain/createSkeletonSettingsDiff.sh
    fi

    if [[ "$GUI_DOMAIN_MAIN_CHOICE" == "PKIPath" ]]; then
        source ./gui/domain/setEasyRSAPKIPath.sh
    fi


    if [[ "$GUI_DOMAIN_MAIN_CHOICE" != "<--" ]]; then
        source ./gui/domain/main.sh
    fi

    if [[ "$GUI_DOMAIN_MAIN_CHOICE" == "<--" ]]; then
        return 0
    fi

    return 0

fi

if [[ "$EXIT_STATUS" -eq 1 ]]; then
    return 0
fi
