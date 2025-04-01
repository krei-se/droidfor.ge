#!/bin/bash

functions/adbChecks.sh
if [ $? -ne 0 ]; then
    echo "One ore more ADB checks failed"
    exit 1
fi

source ./functions/getUserIdFromPackageName.sh

# This script tries to query your local DNS for the domains CA Cert and saves it in /sdcard on the device.
# Mostly for internal services so you don't have to manually provision this

# this works by adding a TXT-Record to ed25519._tlsa.host.domain.tld pointing to the https-server offering the cert for download

# you can do this in opnsense (enable TXT-comment support in unbound)
#   define a host, override or alias with ed25519._tlsa.host.domain.tld pointing to host.domain.tld and just add the https-path to the cert in the description:
#   
# in openwrt you can add TXT-Records in /etc/dnsmasq.conf:
#   txt-record=ed25519._tlsa.host.domain.tld,"https://certs.domain.tld/host.domain.tld.crt"

# This is not an RFC-Standard, use this internally only if you know what you are doing!!!

CERTHOSTS=("ca" "ldap" "vpn")

if [[ -z "$DROIDFORGEAUTOPROVISIONDOMAIN" ]]; then
    echo "Do not run this script outside adminAutoProvision, youll miss the DROIDFORGEAUTOPROVISIONDOMAIN env"
    exit 1
fi

adb shell "mkdir -p /sdcard/certs"

# Loop through each host in the CERTHOSTS array
for certhost in "${CERTHOSTS[@]}"; do
    # Query the TXT record for the ed25519._tlsa.<host>.<domain> and retrieve the URL
    URL=$(dig +short TXT "ed25519._tlsa.${certhost}.${DROIDFORGEAUTOPROVISIONDOMAIN}" | sed 's/"//g')

    # Check if URL was found
    if [ -z "$URL" ]; then
        echo "Error: No URL found for $certhost.$DROIDFORGEAUTOPROVISIONDOMAIN"
        continue
    fi

    # Download the certificate using curl
    curl -o "/tmp/$certhost.$DROIDFORGEAUTOPROVISIONDOMAIN.crt" "$URL"
    
    # Push the certificate to the device
    adb push "/tmp/$certhost.$DROIDFORGEAUTOPROVISIONDOMAIN.crt" /sdcard/certs/
done

adb shell am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file:///sdcard/
adb shell am broadcast -a android.intent.action.MEDIA_MOUNTED -d file:///sdcard/

