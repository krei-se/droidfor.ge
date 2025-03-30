#!/bin/bash

# Please remember these will get called with working directory droidfor.ge/ not skeleton/taskScripts

functions/checkUserHasAdbAndRsyncLocally.sh
if [ $? -ne 0 ]; then
    echo "Please install adb and rsync. apt install android-tools-adb rsync Exiting..."
    exit 1
fi

functions/checkAdbDeviceConnection.sh
if [ $? -ne 0 ]; then
    echo "🍨Device not connected! Exiting..."
    exit 1
fi

functions/checkAdbHasRoot.sh
if [ $? -ne 0 ]; then
    echo "🍨Device is not running in adb rooted mode! Install and setup Magisk. Exiting..."
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

