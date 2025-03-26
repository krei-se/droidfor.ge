#!/bin/bash

mkdir -p initialApps

# Needed in any case
PACKAGES=("com.termux" "com.termux.boot" "com.topjohnwu.magisk")

# Add OpenVPN, DAVx5 and jtx Board if you want or others like this:
PACKAGES+=("de.blinkt.openvpn" "at.bitfire.davdroid" "at.techbee.jtx")

fetch_fdroid_apk() {
    local PACKAGE_NAME="$1"

    if [ -z "$PACKAGE_NAME" ]; then
        echo "Usage: fetch_fdroid_apk <package_name>"
        return 1
    fi

    # Get the latest version info from the F-Droid API
    local API_URL="https://f-droid.org/api/v1/packages/$PACKAGE_NAME"

    local RESPONSE=$(curl -s "https://f-droid.org/api/v1/packages/$PACKAGE_NAME")

#    local VERSION_CODE=$(curl -s "$API_URL" | jq -r '.suggestedVersionCode')
    local VERSION_CODE=$(echo "$RESPONSE" | sed -n 's/.*"suggestedVersionCode":\([0-9]*\).*/\1/p')


    if [ -z "$VERSION_CODE" ] || [ "$VERSION_CODE" == "null" ]; then
        echo "Failed to find latest version for package: $PACKAGE_NAME"
        return 1
    fi

    # Construct the APK download URL
    local APK_URL="https://f-droid.org/repo/${PACKAGE_NAME}_${VERSION_CODE}.apk"

    echo "Downloading APK for $PACKAGE_NAME (version code: $VERSION_CODE) from: $APK_URL"
    curl -L -o initialApps/"${PACKAGE_NAME}.apk" "$APK_URL"

    echo "Download complete: ${PACKAGE_NAME}.apk"

}

    for PACKAGE in "${PACKAGES[@]}"; do
        fetch_fdroid_apk "$PACKAGE"
    done

