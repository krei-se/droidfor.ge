#!/bin/bash

# Run adb devices command and capture output
OUTPUT=$(adb root 2>&1)

# Check if output matches expected messages
if [[ "$OUTPUT" == "restarting adbd as root" || "$OUTPUT" == "adbd is already running as root" ]]; then
    echo "ADB is running as root."
else
    echo "Unexpected output from adb root: $OUTPUT"
    exit 1
fi
