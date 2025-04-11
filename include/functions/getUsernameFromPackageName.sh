#!/bin/bash

get_username_from_packagename() {
    package_name=$1
    uid=$(adb shell pm list packages -U | grep "$package_name " | awk -F'uid:' '{print $2}' | tr -d '[:space:]' | cut -d',' -f1)

    if [[ -n "$uid" ]]; then
        # Extract the last three digits of the UID
        app_id=${uid: -3}
        echo "u0_a$app_id"
    else
        echo "Package not found or error retrieving user ID" >&2
        return 1
    fi
}
