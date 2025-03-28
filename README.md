# 🤖 droidfor.ge - Bending Androids juuuuust right

 Auto provisioning and timer based no-touch backup solution for android fleet devices from .android/$devicename profiles

☠️☠️☠️ This is meant for use in a managed domain at home or at a company and thus involves a rather large category with many interconnected morphisms / tasks you have to adhere to. There is no other usecase but to integrate the devices safely and in large numbers into your domain without installing strange manage-apps or MDM vendorlock to it. You need working DNS/DHCP across wifi and vpn, should have OpenLDAP and kerberized NFS - if you do not know what any of these do and don't have a working managed domain this tool is not the right rool for you ☠️☠️☠️

This will turn your androids into somewhat working and secure linux machines without raising your pinky all that much. I wrote this to have customers get usable devices in the managed domains i set up which provide an environment that has certain standards like NFS-Servers at shares.domain.tld or homes.domain.tld - you can skip those, but it's meant for these mainly.

If you are used to having control over a reproducible setup for your debian-machine this tool is the right tool for you.

If you want to customize this to your usecase just fork it, issues should be about the usecase here, not yours!

Its roughly 2-step:

- An 👨‍🏭 Admin sets up a 🩻 skeleton with apps and settings to autoprovision the device in a domain. You can use the skeleton to setup 100s of devices in one day, only need to enable dev options and adb. (0 -> N and 0 -> 1).

    For customers running 100s of roadwarriors you can use the openvpnKey-folder for openvpn and provision the devices key and cert automatically. This is the only "key" you store on the device, so make sure you can mark the key revoked even though it lives on encrypted internal storage. Without openvpn your devices can only be synced while in Wifi which you DO NOT WANT. Your device will not get lost while logged in wifi but outside on trips. Use OpenVPN!

- All 👶 Users set up their fresh device once (1 -> 1), then only periodically run `backup.sh` from a domain server or the userspace session. You can backup manually or by cron /systemD Service so the user can lose the device safely. You only need adb keys for app backups, all "normal" data can be pulled via rsync. If you have a roaming nfs-home server its easy to just use the ssh and adb keys from the users home to do this without the user having to start this in userspace.

Restoring the device means an admin will autoprovision a new one, then the user runs `restore.sh` once with his .android/$devicename backup.

### Supported Devices:

- Lineage >=22
- Adheres to AOSP, Slot A/B
- unlocked bootloader ofc and root.

Those are modern Motorola and Sony Xperia devices afaik only. Do not believe any lies from vendors about devices needing to be non-root. The only safe way to store data is a luks2 container. Do not use banking apps and carry your bank card seperately from the device. Both can be safely locked if they get lost.

### Security Addons:

- I provide setups for termux to use a LUKS-encrypted container on the SD card. This way you can lose the phone safely without an attacker knowing who it belongs to. You revoke the openvpn-keys, remote erase if you still can and sleep well.

- There is also the possibility to simply mount the users NFS-kerberized home onto the device. This is recommended for all personal files as they will not be stored on the device in any way.

### Comfort Addons:

- Script to inotify-watch the DCIM folder and sync all photos to the users home. This expects a homes. host but you can easily modify the script.

# 👨‍🏭 Admin tasks for all fleet devices

This is a long part, but you only have to do this once for the whole domain.

All scripts are simple morphisms to not overcomplicate things and allow you to change behaiviour with simple task-scripts or files added in. To start you set up 1 🥼 vanilla device as a donor for settings you want set across all fleet devices.

## 🌱 0 -> N Initial - App download and 🥼 Vanilla Device Settings Grab (Admin)


- Run `updateInitialApps.sh` to pull Apps from F-Droid that will be installed on all devices, you can just add packages from fdroid for the usecase that covers all your fleet devices in the domain. The script automatically grabs the latest version. Add Aurora-Store if you must use any Apps from Playstore.

- Buy a compatible, unlockable device with Slot A/B Support from Motorola or Sony and do not use other vendors.

- Install Lineage, you don't need any gapps addons, but if you are lazy you can flash magisk as a zip already and save on one restart after inital Apps install.

- Connect this fresh 🥼 vanilla lineage device. Enable ADB.

- Run `installInitialApps.sh` with the 🥼 vanilla device attached. We need termux and magisk at the very minimum to continue with a rooted device. You can use this script on fleet devices too, but autoprovisioning will take care of the initial Apps there.

Now on the 🥼 vanilla device make sure Magisk works, then enable adb root in developer settings.

- Run `grabVanillaSkeletonSettings.sh` with the 🥼 vanilla device attached to grab a source for the settings skeleton. You can find the settings-dump in `skeleton/vanilla` This will restart adb in rootmode.

## 🩻 0 -> 1 Initial - Customize the skeleton

Now on the so far vanilla device change all settings you want captured and later set on all devices in the fleet. If you need a custom wallpaper or ringtone you can place files you want on all devices into `skeleton/sdcard` - these will be copied to the internal mmc.

Run `createSkeletonSettingsDiff.sh` - this script diffs your settings into `skeleton/settings` and removes some settings that i noticed will change during setup (screen brightness, charging time, etc.)

These scripts take no arguments, so make sure it's the only device attached.

🔕 Note on ringtones: I will not implement the logic needed to change the default sounds as android uses some magic MediaID that will no be the same on 2 different devices. If you really insist on forcing a ringtone, chargetone, whatever onto the user outside offering it via sdcard/Ringtones you can use a script and figure it out yourself. I leave the functionality to do it out of the scope of droidfor.ge so you don't nag your employees with some stupid dancing company-jingle or sth.

Note on input settings: If you want to customize the default keyboard that comes with lineage, the package name is `com.android.inputmethod.latin` and can be backupped from the skeleton device and be placed into skeleton/apps.

# 👨‍🏭 Admin tasks per device

With the skeleton ready for the fleet, provision the devices one by one for each user. We only take 1 device at a time so make sure its the only one connected via adb. We don't use serials here as you will not know these beforehand and only need to do this once per device. After that the device is reachable via hostname anyway and wont need to be connected via wire.

## 🍨 1 -> N Morph - Admin-provision the device for the user

Take a new vanilla device your user is eagerly awaiting and enable ADB.

- Run `adminProvision.sh devicename.domain.tld user@domain.tld`

Here's what this script will do in complete order

1. Installs the initial Apps first. Now acknowledge to the script that the device is rooted.
2. Applies all skeleton/settings via `adb shell settings set`
3. Set device_name and bluetooth_name to the first part of the FQDN (devicename.domain.tld -> devicename)

4. Runs all admin-tasks-scripts in skeleton/adminTasksScripts. See the folder for details, here are the default scripts and you can ofc already add some:
    1. `001-enableFixedAdbWirelessViaWiredAdb` - what the filename says
    2. `010-copyInternalStorageContent` - copies skeleton/sdcard to the internal storage via rsync (fast, can do gigabytes. Lineage provides rsync, see the script how it works if you like that. But as its rather complicated we use the sshd termux rsync later for backups)
    3. `100-grabDomainED25519CACerts` - this is not optimal yet or standarized RFC, but it asks the local DNS for the TXT-Records of self-signed ED25519-CAs for a set list of hosts (ca. ldap. and vpn.) then saves these to the device on `/sdcard/certs/` for use in OpenVPN and OpenLDAP. See the script for details how to publish self-signed ed25519 cas in your domain using opnsense or openwrt and a webserver

    4. `200-openvpnConfig` - copying all files from `skeleton/openvpn` to `/sdcard/openvpn`
    5. `201-openvpnDeviceCerts` - if found in openvpnKeys/ copies the device fqdn cert from f.e. `openvpnKeys/$devicename.domain.tld.crt/key` to `/sdcard/openvpn/device.crt/key` - the files are fixed called device.crt and device.key so you can apply a general profile across the fleet. If a ca.domain.tld record is found via DNS-TXT it will be copied to ca.crt.
    6. `300-termuxBasicSetup` - Installs the normal repository and some basic packages, enables external storage setup and then copies the content of `skeleton/termux` into the termux home directory. If you install Termux:Boot the default contents of .termux/boot make sure sshd is started.
    7. `500-skeletonApps` - Installs all apps in skeleton/apps. See the caption about manually backing up and restoring single apps. This can be used to set the default input keyboard f.e.

The device is now ready to hand over to the user for further initial Setup and restore.

# 👶 User tasks per device

Your user should have a working adb .android folder and keys in .ssh.

We save all backups and config in .android/$deviceName. The backup script will loop all folders and take the one with "droidforge" empty file in it. This folder gets set up during userProvision.sh

## 🧺 1 -> 1 Morph - User-provision the device

Connect the 🏗️ adminProvisioned device in the usersession via wire. If your user is not present but you have an nfs-server with his home folder do this remotely. I'm sure there is a way to add the adb keys somewhat easier and may make this easier in the future. Right now that's the way it goes.

As the user, run `userProvision.sh devicename.domain.tld user@domain.tld`

Here's what this script will do in complete order

1. Adds the users public ssh keys into `/data/data/com.termux/files/home/.ssh/authorized_keys`


## copy the users .ssh keys to termux for rsync to work.

## 🎒 1 -> N Copy the skeleton to .android/$deviceName (Admin)

Now copy your skeleton folder for a device not provisioned yet to $HOME./android/$devicename. All settings you change will be updated only once during autoprovisioning of the device.

Your devicename can contain dots for a FQDN like yourdevicename.domain.tld



# Autoprovisioning a device for first use (User)

Run ./autoprovision.sh $devicename $serial with an adb enabled wired device. It can be the only device attached or you have to provide the serial once.

This will do the following changes on your Phone in standard, you can change the script ofc:

- Set up the devicename
- Install all initial apps like Termux, Termux: Boot and Magisk Root
- Set adb wireless port fixed to 5555, survives reboots. There is an fixedAdbWireless.sh in your termux home folder too.
- Set up sshd autoboot for the termux user. Place your .ssh keys in $devicename/ssh before provisioning to autocopy them onto the device
- Install the following termux-packages: openssh, rsync, mc, termux-am, cryptsetup

- Run the termux-setup for storage access. This needs root, so make sure magisk is working. You can rerun the autoprovisioning any time needed.

# Static path for SD-Cards

If you want the users SD-Card to be found in a fixed path you can use exfatlabel from exfatprogs to format the card with a fixed UUID like this:

    $sdcardDevicePart is f.e. /dev/sdb1 or /dev/mmbblk0p1 

    root@linux:~# apt install exfatprogs 
    root@linux:~# exfatlabel /dev/$sdcardDevicePart 512GB-SD
    root@linux:~# exfatlabel /dev/$sdcardDevicePart -i 0x12340512
    root@linux:~# lsblk --fs
    NAME   FSTYPE FSVER LABEL UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
    sdb                                                                           
    └─sdb1 exfat  1.0   512GB-SD 1234-0512                                           
                                                         
    
This will set the drives label NAME to "512GB-SD" and the UUID to 1234-0512. I recommend using the uid of the user the device will be provisioned to as the first part and the GB-size as the second.

You can then access the external-sd in a reproducible manner, like `/storage/1234-0512` on the phone. exfatprogs is also available for android in termux if you want to do it there, you can even set this up as a script, take the 300-termux-setup as a template on how to automatically do termux commands via adb.

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

This program only uses adb wireless when the device is in range to backup your apps and appdata. Specify the packagenames you want backupped in $device/apps

Run ./backup.sh $devicename in a cron. Your device should be reachable via devicename as hostname with no domain added and listen on ADB wireless port 5555.

There is no authentification outside the adb keys!!

# What this program won't do

- Save Call History or complex app profiles like packages.xml
- Save Wallpapers or other settings

Never save critical data outside /sdcard / /storage/emulated/0 - files in /storage/external on your SD-Card are not encrypted and can be read by an attacker. Only use LUKS-Containers on the sdcard!!