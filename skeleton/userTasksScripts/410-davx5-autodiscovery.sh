#!/bin/bash

functions/adbChecks.sh
if [ $? -ne 0 ]; then
    echo "One ore more ADB checks failed"
    exit 1
fi

source ./functions/getUserIdFromPackageName.sh

# Fetch the SRV record
SRV_RECORD=$(dig +short SRV "_caldavs._tcp.${DROIDFORGEAUTOPROVISIONDOMAIN}." | sed 's/"//g')

# Check if SRV record was found
if [ -z "$SRV_RECORD" ]; then
  echo "No SRV record found for _caldavs._tcp.${DROIDFORGEAUTOPROVISIONDOMAIN}."
  echo "Skipping autodiscovery for Davx5"
  exit 0
fi

# Extract the port and hostname from the SRV record
DAVPORT=$(echo $SRV_RECORD | awk '{print $3}')
DAVHOSTNAME=$(echo $SRV_RECORD | awk '{print $4}')

# Print the results
echo "Host: $DAVHOSTNAME"
echo "Port: $DAVPORT"

echo 

read -sp "Enter the password for $DROIDFORGEAUTOPROVISIONUSERACCOUNT or just press enter to leave it empty: " DROIDFORGEAUTOPROVISIONUSERPASSWORD

adb shell am start -a android.intent.action.VIEW \
  -d "davx5://$DROIDFORGEAUTOPROVISIONUSERACCOUNT:$DROIDFORGEAUTOPROVISIONUSERPASSWORD@$DAVHOSTNAME:$DAVPORT"

# Sorry that's the furthest i can automate this for now.

