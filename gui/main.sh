#!/bin/bash

if [[ -z DF_RANMAIN ]]; then
    echo "please don't run these scripts separately, use ./droidfor.ge.sh in the projects root"
    exit 1
fi


term_width=$(tput cols)
term_height=$(tput lines)

term_width=${term_width:-80}
term_height=${term_height:-24}

export WT_WIDTH=$(awk "BEGIN {print int($term_width * 0.90)}")
export WT_HEIGHT=$(awk "BEGIN {print int($term_height * 0.75)}")


#export WT_MENUHEIGHT=$(awk "BEGIN {print int($WT_HEIGHT * 0.75)}")
export WT_MENUHEIGHT=$(($WT_HEIGHT-10))

# these all work fine, but we actually need around 10 lines always, sooo ....
#export WT_MENUHEIGHT=20

if [[ -n "$DF_DOMAIN_FQDN" ]]; then
    WT_TITLE="🤖 Droidfor.ge for $DF_DOMAIN_FQDN"
else
    WT_TITLE="Welcome to 🤖 Droidfor.ge"
fi

export WT_TITLE

source ./include/functions/configSummary.sh

#    1> success.log   2> error.log
# redirect stderr to stdout: 3>&1 1>&2 2>&3
# 3>$1 means take stdout to 3,
# 1>$2 means take stderr to stdout
# 2>$3 means take 3 now back to stderr (essentially switch stdout and stderr)


GUI_MAIN_CHOICE=$(whiptail --title "$WT_TITLE" --menu "$DF_CONFIG_SUMMARY" $WT_HEIGHT $WT_WIDTH $WT_MENUHEIGHT \
    "Domain" "Setup the domain" \
    "Machine" "Setup the machine" \
    "User" "Setup the user" \
    3>&1 1>&2 2>&3
    )

EXIT_STATUS=$?


if [[ "$EXIT_STATUS" -eq 0 ]]; then

    if [[ "$GUI_MAIN_CHOICE" == "Domain" ]]; then
        source ./gui/domain/main.sh
    fi

    if [[ "$GUI_MAIN_CHOICE" == "Machine" ]]; then
        source ./gui/machine/main.sh
    fi

    if [[ "$GUI_MAIN_CHOICE" == "User" ]]; then
        source ./gui/user/main.sh
    fi

    # return
    source ./gui/main.sh

fi

if [[ "$EXIT_STATUS" -eq 1 ]]; then
    return 0
fi