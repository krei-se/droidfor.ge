#!/bin/bash

getUserIdFromPackageName() {
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

#!/bin/bash

getUidFromPackageName() {
    package_name=$1
    uid=$(adb shell pm list packages -U | grep "$package_name " | awk -F'uid:' '{print $2}' | tr -d '[:space:]' | cut -d',' -f1)

    if [[ -n "$uid" ]]; then
        echo "$uid"  # Directly return the full UID (e.g., 10123)
    else
        echo "Package not found or error retrieving UID" >&2
        return 1
    fi
}
