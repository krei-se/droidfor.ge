#!/bin/bash

COMMAND=$1
OUTPUT_FILE="output.txt"
SLEEP_DURATION=2  # Adjust as needed

# Send the command to Termux
adb shell am startservice --user 0 \
    -n com.termux/.app.RunCommandService \
    -a com.termux.RUN_COMMAND \
    --es com.termux.RUN_COMMAND_PATH '/data/data/com.termux/files/usr/bin/bash' \
    --esa com.termux.RUN_COMMAND_ARGUMENTS '-c', "${COMMAND} > ${OUTPUT_FILE} 2>&1" \
    --es com.termux.RUN_COMMAND_WORKDIR '/data/data/com.termux/files/home' \
    --ez com.termux.RUN_COMMAND_BACKGROUND false

# Wait for the command to execute
sleep ${SLEEP_DURATION}

# Retrieve and display the output
adb shell cat /data/data/com.termux/files/home/${OUTPUT_FILE}
