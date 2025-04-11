#!/bin/bash

get_uid_from_packagename() {
    package_name=$1
    uid=$(adb shell pm list packages -U | grep "$package_name " | awk -F'uid:' '{print $2}' | tr -d '[:space:]' | cut -d',' -f1)

    if [[ -n "$uid" ]]; then
        echo "$uid"  # Directly return the full UID (e.g., 10123)
    else
        echo "Package not found or error retrieving UID" >&2
        return 1
    fi
}
