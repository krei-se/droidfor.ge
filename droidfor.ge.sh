#!/bin/bash

export DF_RANMAIN=true

term_width=$(tput cols)
term_height=$(tput lines)

term_width=${term_width:-80}
term_height=${term_height:-24}

export WT_WIDTH=$(awk "BEGIN {print int($term_width * 0.90)}")
export WT_HEIGHT=$(awk "BEGIN {print int($term_height * 0.75)}")

if [[ WT_WIDTH -lt 40 || WT_HEIGHT -lt 20 ]]; then
echo $WT_HEIGHT
    echo "Your terminal is too small"
    exit 1
fi

#export WT_MENUHEIGHT=20
export WT_MENUHEIGHT=$(($WT_HEIGHT-10))


# see https://gist.github.com/ymkins/bb0885326f3e38850bc444d89291987a

export color_orange="#ff8800"
export color_orange_inactive="#ffdd88"
export color_droid="#207E8B"
export color_domain="#B0301F"
export color_machine="#1B06CD"
export color_user="#03A80A"

export NEWT_COLORS="
    root=,$color_droid  
    border=black,lightgray
    window=lightgray,lightgray
    shadow=black,black
    title=black,lightgray
    button=black,$color_orange
    actbutton=white,$color_orange
    compactbutton=black,lightgray
    checkbox=black,lightgray
    actcheckbox=lightgray,$color_orange
    entry=black,lightgray
    disentry=gray,lightgray
    label=black,lightgray
    listbox=black,lightgray
    actlistbox=lightgray,$color_orange_inactive 
    sellistbox=white,$color_orange
    actsellistbox=white,$color_orange  
    textbox=black,lightgray
    acttextbox=white,$color_orange
    emptyscale=,gray
    fullscale=,$color_orange
    helpline=white,black
    roottext=lightgrey,black
"
export WT_SIZE="$WT_HEIGHT $WT_WIDTH"

# Welcome
WELCOME_MESSAGE="\n\n\
Droidfor.ge helps you setup your Android devices inside a managed domain \n\
\n\
To make sure this works, we follow a domain - machine - user workflow"

whiptail --title "Welcome to Droidfor.ge" --msgbox "$WELCOME_MESSAGE" $WT_SIZE --fb 

#whiptail --title "My Dialog" --backtitle "" --msgbox "Looks like a transparent background!" 10 50

echo "Running some initial ADB checks"
source ./gui/adb/checks.sh

echo "Running ADB device select"
source ./gui/adb/selectDevice.sh

echo "Running domain and services autodetection ..."
source ./gui/domain/autodetect.sh

source ./gui/main.sh