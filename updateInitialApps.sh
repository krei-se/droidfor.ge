#!/bin/bash

mkdir -p initialApps

# If you get the error that the app is not compatible ABI, add :[int] to the package name.
# It will get all versions from the api and take the one with this integer ending.
# https://f-droid.org/de/packages/org.videolan.vlc/ f.e. will give you x86 with :8 and armv8 with :6

# Needed in any case
PACKAGES=("com.termux" "com.termux.boot" "com.topjohnwu.magisk")

# Add OpenVPN, DAVx5 and jtx Board if you want or others like this:
PACKAGES+=("de.blinkt.openvpn" "at.bitfire.davdroid" "at.techbee.jtx")

# Stores
#    PACKAGES+=("com.aurora.store" "org.fdroid.fdroid")

# Media
#    PACKAGES+=("ch.blinkenlights.android.vanilla" "org.videolan.vlc:6")

# Social
#    PACKAGES+=("org.quantumbadger.redreader" "nl.viter.glider")

 

fetch_fdroid_apk() {
    local PACKAGE_NAME="$1"

    if [ -z "$PACKAGE_NAME" ]; then
        echo "Usage: fetch_fdroid_apk <package_name>"
        return 1
    fi

    # Check if the package name contains a colon
    local VERSION_SUFFIX=""
    if [[ "$PACKAGE_NAME" == *:* ]]; then
        # Split the package name and the version suffix
        VERSION_SUFFIX="${PACKAGE_NAME##*:}"
        PACKAGE_NAME="${PACKAGE_NAME%%:*}"
    fi

    # Get the latest version info from the F-Droid API
    local API_URL="https://f-droid.org/api/v1/packages/$PACKAGE_NAME"

    local RESPONSE=$(curl -s "https://f-droid.org/api/v1/packages/$PACKAGE_NAME")


    # If there's a version suffix, search for the correct version code that ends with the suffix
    if [ -n "$VERSION_SUFFIX" ]; then
        # Filter the versionCodes and pick the first one that ends with VERSION_SUFFIX
        local VERSION_CODE=$(echo "$RESPONSE" | jq -r ".packages[].versionCode" | grep -E "${VERSION_SUFFIX}$" | head -n 1)
    else
        # Default behavior: fetch the latest version code
        local VERSION_CODE=$(echo "$RESPONSE" | jq -r '.suggestedVersionCode')
    fi

    if [ -z "$VERSION_CODE" ] || [ "$VERSION_CODE" == "null" ]; then
        echo "Failed to find the correct version for package: $PACKAGE_NAME"
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

