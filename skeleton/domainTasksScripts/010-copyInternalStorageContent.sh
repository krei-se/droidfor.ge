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

# pull the Archer Mulatto Butts Ringtone in any case
mkdir -p skeleton/internalStorage/Ringtones
curl -L https://archive.org/download/tvtunes_26263/Archer%20-%20Mulatto%20Butts.ogg -o skeleton/internalStorage/Ringtones/mulattobutts.ogg

# creates a remote rsync service on the adb enabled device, then forwards the port.
adb push skeleton/adminTasksScripts/remoteRsync.conf /sdcard/remoteRsync.conf
adb forward tcp:2137 tcp:2137

adb shell "su -c 'rsync --daemon --config=/sdcard/remoteRsync.conf &'"
adb shell "ps | grep rsync"

# dont worry the /root here is the sdcard
rsync -avz --no-times --no-group --exclude=".gitkeep" --progress --stats skeleton/internalStorage/ rsync://localhost:2137/root/

adb shell "su -c 'killall rsync'"
adb shell "rm /sdcard/remoteRsync.conf"

# refresh the media storage to prevent users bugging me why mulatto butts is not playing

adb shell am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file:///sdcard/
adb shell am broadcast -a android.intent.action.MEDIA_MOUNTED -d file:///sdcard/

# Now if someone complains about the ringtone tell them to actually take a look inside .sh scripts they run


# adb shell "settings put system ringtone content://0@media/external/audio/media/1000009023?title=mulattobutts&canonical=1"

