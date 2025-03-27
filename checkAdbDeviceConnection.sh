#!/bin/bash

# Run adb devices command and capture output
adb_output=$(adb devices)

# Count the number of lines in the output
line_count=$(echo "$adb_output" | wc -l)

# Check if there are exactly two lines: one for the header and one for the device
if [ "$line_count" -ne 2 ]; then
  echo "Error: More than one or no device found."
  exit 1
fi

# Check if the second line contains "device" and not "unauthorized"
if echo "$adb_output" | tail -n 1 | grep -q "device"; then
  echo "Device is properly connected and authorized."
else
  echo "Error: Device is not in a proper state. Authenticate the device."
  exit 1
fi
