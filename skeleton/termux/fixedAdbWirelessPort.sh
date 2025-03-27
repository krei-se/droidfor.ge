#!/data/data/com.termux/files/usr/bin/sh
su -c "setprop adb.tcp.port 5555"
su -c "setprop persist.adb.tcp.port 5555"
su -c "stop adbd"
su -c "start adbd"
getprop adb.tcp.port
getprop persist.adb.tcp.port
