# droidfor.ge
Simple auto provisioning and backup solution for android fleet devices from .android/$devicename profiles

This is meant for 2 usecases:

- Admin autoprovisioning of initial device setup. You can set up 100s of devices in one go, only enable dev options and adb.
- User croned backup from a home server or the userspace session. You can backup manually or by cron so the user can lose the device safely.

For restoring a device you need both the company-policy wide skeleton which the admin should keep a copy of and the users $device-folder in $HOME/.android

# Howto

## 1. Initial Apps Download

Run init.sh to pull Apps that will be installed on all devices, you can change what to download for the usecase that covers all your fleet devices in the domain.

## 2. Skeleton Sync

Sync from a vanilla device a skeleton for the settings App. This will serve as a diff what settings to change during auto provisioning. I provide a commented skeleton for lineage-Devices running the latest version.

## 3. Copy the skeleton to $deviceName

Now copy your skeleton folder to devicename. All settings you change will be updated only once during autoprovisioning of the device.

# Autoprovisioning

Run ./autoprovision.sh $devicename with an adb enabled wired device. It can be the only device attached or you have to set the serial in $device/serial

This will do the following changes on your Phone in standard, you can change the script ofc:

- Install Termux, Termux: Boot and Magisk Root
- Set adb wireless port fixed to 5555, survives reboots. There is an fixedAdbWireless.sh in your termux home folder too.
- Set up sshd autoboot for the termux user. Place your .ssh keys in $devicename/ssh before provisioning to autocopy them onto the device
- Install the following termux-packages: openssh, rsync, mc, termux-am

- Run the termux-setup for storage access. This needs root, so make sure magisk is working. You can rerun the autoprovisioning any time needed.

## App Files

I only provide profiles in skeleton for the following apps:

- OpenVPN for Android: https://f-droid.org/de/packages/de.blinkt.openvpn/
    + Copy to $devicename/openvpn - these will be copied to the internal storage /sdcard/vpn, take a look at skeleton/vpn

This will not install any profile in the OpenVPN-App, you have to select the certs and profile there once

- DAVx5
    + Copy to $devicename/dav your profiles, you can find all settings in the skeleton/dav folder

There is no autosetup for FairMail yet as you might use another E-Mail app.

# Croned Backup

This program won't sync any data, but you have sshd in termux for that!

This program only uses adb wireless when the device is in range to backup your apps and data. Specify the packagenames you want backupped in $device/apps

Run ./backup.sh $devicename in a cron. Your device should be reachable via devicename as hostname with no domain added and listen on ADB wireless port 5555.

There is no authentification outside the adb keys!!