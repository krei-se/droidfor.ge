#!/data/data/com.termux/files/usr/bin/sh
# This is an example file you can use to run via adb in termux during domainProvisioning, see 301-termuxSkeleton.sh

echo "Running domainSetup.sh inside termux!"
sleep 2

TERMUX_PKG_NO_MIRROR_SELECT=true

# Note that busybox is very crippled on android

yes | pkg install -y openssh termux-am rsync mc busybox


# DNS Stuff
yes | pkg install -y dnsutils

# Inotify-tools für Komfort-Funktion Camera-Sync

yes | pkg install -y inotify-tools


# openssh installs host-keys in /data/data/com.termux/files/user/etc/ssh


# remove the setup script here
rm domainSetup.sh
echo "Deleted domainSetup.sh!"

sleep 5
