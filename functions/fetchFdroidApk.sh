#!/bin/bash

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
