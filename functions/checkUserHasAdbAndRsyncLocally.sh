#!/bin/bash

# Check if adb is installed
if ! command -v adb >/dev/null 2>&1; then
    echo "❌ Error: adb is not installed. Exiting."
    exit 1
fi

#echo "✅ adb is installed, continuing script..."

# Check if rsync is installed
if ! command -v rsync >/dev/null 2>&1; then
    echo "❌ Error: rsync is not installed. Exiting."
    exit 1
fi

#echo "✅ rsync is installed, continuing script..."
