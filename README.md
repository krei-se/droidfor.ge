# droidfor.ge
Simple auto provisioning and backup solution for android from .android/$devicename profiles

# Howto

## 1. Initial Apps Download

Run init.sh to pull Apps that will be installed on all devices, you can change what to download for the usecase that covers all your devices in the domain

## 2. Skeleton Sync

Sync from a vanilla device a skeleton for the settings App. This will serve as a diff what settings to change during auto provisioning

## 3. Copy the skeleton to $deviceName

Now copy your skeleton folder to devicename. All settings you change will be updated only once during autoprovisioning of the device

# Croned Backup

This program won't sync any data, but you have sshd in termux for that!

This program only uses adb wireless when the device is in range to backup your apps and data. Specify the packagenames you want backupped in $device/apps

Run ./backup.sh $devicename in a cron. Your device should be reachable via devicename as hostname with no domain added and listen on ADB wireless port 5555.

There is no authentification outside the adb keys!!