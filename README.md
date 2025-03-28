# 🤖 droidfor.ge - Bending Androids juuuuust right

Auto provisioning and Backup/Restore solution for android fleet devices.

Built for Phones with unlockable bootloaders, thus rootable lineage devices, also SD-Cards and A/B Slot Support (Motorola and Sony mostly)

- <text style="color: #FF0000">Domain</text>: An 👨‍🏭 Admin sets up a 🩻 skeleton settings template via a 🥼 Vanilla Device for the Managed Domain.

- <text style="color: #0000FF">Machine</text>: The 👨‍🏭 Admin then integrates each device into the Managed Domain.

- <text style="color: #00FF00">User</text>: All 👶 Users set up their fresh device once, backup is done transparent via the nfs home file server or manually in the userspace session.

Turns your android phones into rooted, but secure and usuable domain clients. No Clouds!

# 👨‍🏭 <text style="color: #FF0000">Domain</text> : for all devices

## 🍨 0 -> N Initial Preseeding

- Run `updateInitialApps.sh` to pull Apps from F-Droid that will be installed on all devices

You can just add packages from fdroid in the script, it automatically grabs the latest version and allows to select versions ending in a certain integer if you need a specific architecture build . Add Aurora-Store if must use any Apps from Playstore.

Install Lineage on a wiped device. You don't need any gapps addons, but if you are lazy you can flash magisk as a zip already.

Connect this fresh 🥼 vanilla lineage device. Enable ADB.

- Run `installInitialApps.sh` with the 🥼 vanilla device attached.

On the 🥼 vanilla device make sure 🤿 Magisk works, then enable adb root in developer settings.

- Run `grabVanillaSkeletonSettings.sh` with the 🥼 vanilla device attached to grab a source for the settings skeleton.

You can find the settings-dump in `skeleton/vanilla`.

Use the same device now as the 🩻 skeleton device

## 🩻 0 -> 1 Initial - Customize the skeleton

On the now 🩻 skeleton device you can customize settings you want on all devices in the domain / fleet.

Run `createSkeletonSettingsDiff.sh` - this script diffs your settings into `skeleton/settings` and removes some settings that i noticed will change during setup (screen brightness, charging time, etc.)

These scripts take no arguments, so make sure it's the only device attached.

⌨️ It will ask if you want the input method captured too and save this to `skeleton/com.android.inputmethod.latin_preferences.xml` for a later task to pick up. Note this is a user-profile setting.

🔕 Note on ringtones: Ringtones are hard to autoprovision right, so they are wiped from the skeleton settings. Implement a task if you need this, i recommend only offering a ringtone via skeleton/sdcard/Ringtones and not force one onto the user.

# 👨‍🏭 <text style="color: #0000FF">Machine</text> : for a specific device

With the skeleton ready for the domain, provision the devices one by one.

We only setup 1 device at a time so make sure its the only one connected via adb. This way you don't need serials here as you will not know these beforehand. After that the device is reachable via hostname anyway and wont need to be connected via wire. You can also keep spare devices in the domain this way and set them up for a user in no-time.

## 🚢 1 -> N Morph - Domain-provision the device

Take another fresh device. Only ADB, Magisk and ADB root needed.

Just flash Magisk after lineage as zip, run it once, check its not complaining and allow adb shell su-rights. initial Apps will be installed during the setup.

- Run `domainProvision.sh devicename.domain.tld`

Here's what this script will do in complete order

1. Installs the initial Apps first. If you forgot or dont want to install Magisk via Zip acknowledge to the script that the device is rooted.
2. Applies all skeleton/settings via `adb shell settings set`
3. Set device_name and bluetooth_name to the first part of the FQDN (<b><font color="0000FF">devicename</font>.<font color="#FF0000">domain.tld</font> -> <font color="#0000FF">devicename</font></b>)

4. Runs all domain-tasks-scripts in skeleton/domainTasksScripts. See the folder for details, here are the default scripts and you can ofc already add some:
    1. `001-enableFixedAdbWirelessViaWiredAdb` - what the filename says
    2. `010-copyInternalStorageContent` - copies skeleton/sdcard to the internal storage via rsync (fast, can do gigabytes. Lineage provides rsync, see the script how it works if you like that. But as its rather complicated we use the sshd termux rsync later for backups)
    3. `100-grabDomainED25519CACerts` - this is not optimal yet or standarized RFC, but it asks the local DNS for the TXT-Records of self-signed ED25519-CAs for a set list of hosts (ca. ldap. and vpn.) then saves these to the device on `/sdcard/certs/` for use in OpenVPN and OpenLDAP. See the script for details how to publish self-signed ED25519 CAs in your domain using opnsense or openwrt and a certs.webserver

    4. `200-openvpnConfig` - copying all files from `skeleton/openvpn` to `/sdcard/openvpn`
    5. `201-openvpnDeviceCerts` - if found in openvpnKeys/ copies the device fqdn cert from f.e. `openvpnKeys/$devicename.domain.tld.crt/key` to `/sdcard/openvpn/device.crt/key` - the files are fixed called device.crt and device.key so you can apply a general profile across the fleet. If a ca.domain.tld record is found via DNS-TXT it will be copied to ca.crt.
    6. `300-termuxBasicSetup` - Installs the normal repository (deb https://packages.termux.dev is in Germany, Falkenstein) and some basic packages (see script), enables external storage setup and then copies the content of `skeleton/termux` into the termux home directory. If you install Termux:Boot the default contents of .termux/boot make sure sshd is started.
    7. `500-skeletonApps` - Installs all apps in skeleton/apps. See the caption about manually backing up and restoring single apps. This can be used to set the default input keyboard f.e.


- Run `userProvision.sh user@domain.tld`

5. Runs all user-tasks-script in skeleton/userTasksScripts. See the folder for details, just remember these tasks 

The device is now ready to hand over to the user for further initial Setup and restore.

# 👶 <text style="color: #00FF00">User</text> : for a specific device -> user

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




### Security Addons:

- I provide setups for termux to use a LUKS-encrypted container on the SD card. This way you can lose the phone safely without an attacker knowing who it belongs to. You revoke the openvpn-keys, remote erase if you still can and sleep well.

- There is also the possibility to simply mount the users NFS-kerberized home onto the device. This is recommended for all personal files as they will not be stored on the device in any way.

### Comfort Addons:

- Script to inotify-watch the DCIM folder and sync all photos to the users home. This expects a homes. host but you can easily modify the script.
