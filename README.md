# 🤖 Droidfor.ge 🩻

### Bend your Androids juuust right

- Visit <a href="https://krei.se">Krei.se</a> for updates and how to build a free managed domain (german)
- <a href="https://krei.se/Blog/0ff-personaldevice/050-Mobiles">Buyers Guide for tested phones (german)</a> 

Currently a rewrite is in progress to make droidfor.ge easier to use with a GUI

This project is thus to be considered in a NONWORKING STATE until i rotate my workflow back to cyan space again.

Notes to fix:

- Do RFC 6698 for the ed25519 cert

![GUI](https://raw.githubusercontent.com/krei-se/droidfor.ge/refs/heads/main/menu.png)

### Auto provisioning and syncing for android fleet devices.

Built for Phones with unlockable bootloaders, thus rootable o-O-o lineage devices, also SD-Cards and A/B Slot Support (Motorola and Sony mostly)

- $\color{red}{\textbf{Domain}}$: An 👨‍🏭 Admin sets up a 🩻 skeleton settings template via a 🥼 Vanilla Device for the Managed Domain.

- $\color{blue}{\textbf{Machine}}$: The 👨‍🏭 Admin integrates each device into the Managed Domain.

- $\color{green}{\textbf{User}}$: All 👶 Users set up their fresh device once, backup is done transparent via the nfs home file server or manually in the userspace session.

Turns your android phones into rooted, but secure and usuable domain clients. No Clouds and no management apps!

# 🧘🏻 
As a sideeffect i noticed after finishing this that not only you can lose or break a device now safely (good for the mind) - you can just keep one in every room, they are basically all the same now (good for the body).

## 🪺 App Backup 

Still hit and miss and kinda not part of this project - i need to debug and implement backing up SELinux-context and this will work for more and more apps while i use them, but may never be a general solution. Its a broad topic and solutions like Swift Backup already fail at my testcases too. If you have Apps that Swift Backup etc. wont backup correclty pls open an issue about them, so i have more testcases.

# 🔴 Domain - 🔵 Machine - 🟢 User Workflow

I use this color coded seperation in all of my infrastructure, you need to work on each section, but can scale each infinitely.

# 👨‍🏭 $\color{red}{\textbf{Domain}}$ : for all devices

## 🍨 0 -> N Initial Preseeding

- Run `updateInitialApps.sh` to pull Apps from F-Droid that will be installed on all devices

You can just add packages from fdroid in the script, it automatically grabs the latest version and allows to select versions ending in a certain integer if you need a specific architecture build. Add Aurora-Store if must use any Apps from Playstore.

Install Lineage on a wiped device. You don't need any gapps addons, but if you are lazy you can flash magisk as a zip already.

Connect this fresh 🥼 vanilla lineage device. Enable ADB.

- Run `installInitialApps.sh` with the 🥼 vanilla device attached.

On the 🥼 vanilla device make sure 🤿 Magisk works, then enable adb root in developer settings.

- Run `grabVanillaSkeletonSettings.sh` with the 🥼 vanilla device attached to grab a source for the settings skeleton.

You can find the settings-dump in `skeleton/vanilla`.

Use the same device now as the 🩻 skeleton device

## 🩻 0 -> 1 Initial customization of the skeleton

On the now 🩻 skeleton device you can customize ⚙️ settings you want on all devices in the domain / fleet.

Run `createSkeletonSettingsDiff.sh` - this script diffs your settings into `skeleton/settings[namespace]` and removes some settings that i noticed will change during setup (screen brightness, charging time, etc.)

These scripts take no arguments, so make sure it's the only device attached.

⌨️ It will ask if you want the input method captured too and save this to `skeleton/com.android.inputmethod.latin_preferences.xml` for a later task to pick up. Note this is technically a user-profile setting.

### Notes on stuff i will solve later when needed

Skeleton App Backup/Restore - preferences for apps used on all domain / fleet devices are not implemented yet, rn i never need this because all apps get setup during domainProvisioning and userProvisioning.

🔕 Note on ringtones: Ringtones are hard to autoprovision correctly due to the Media-ID, rn they are wiped from the skeleton settings. Implement a task if you need this, i recommend only offering a ringtone via skeleton/InternalStorage/Ringtones and not force one onto the user. If you f*ck up the Media-ID it will play the wrong file, endlessly, until you restart the device lol.

👥 Note on multiuser-support: All userprovisioning allows to specify the multiuser-id. Create a second user on the device if you want (family-tablet, whatever), but i never use this, so even though basic stuff will copy and work just fine, don't expect all too much at this early stage. The default Owner is 0, second user is 10, etc.

# 👨‍🏭 $\color{blue}{\text{Machine}}$ : for a specific device

With the skeleton ready for the domain, provision the devices one by one.

We only setup 1 device at a time so make sure its the only one connected via adb. This way you don't need serials here as you will not know these beforehand. After that the device is reachable via hostname adb wireless and ssh anyway and wont need to be connected via wire. You can also keep spare devices in the domain this way and set them up for a user in no-time.

## 🚢 1 -> N Morph - Domain-provision the device

Take another fresh device. Only ADB, Magisk and ADB root needed.

Just flash Magisk after lineage as zip, run it once, check its not complaining and allow adb shell su-rights.

If you accidentially disallowed Shell su access you can remove the greyed out Shell in Magisk under "🛡️ Superuser"

- Run `domainProvision.sh devicename.domain.tld`

Here's what this script will do in complete order

- Installs the initial Apps first. If you forgot or dont want to install Magisk via Zip acknowledge to the script that the device is rooted. Magisk may expect you to reboot - do so now, you can just let the script wait.
- Applies all skeleton/settings via `adb shell settings set`
- Set device_name and bluetooth_name to the first part of the FQDN (devicename.domain.tld -> devicename)

Then it runs all domain-tasks-scripts in skeleton/domainTasksScripts. See the folder for details, here are the default scripts and you can ofc already add some:
    
1. `001-enableFixedAdbWirelessViaWiredAdb` - what the filename says, allows Port 5555 adb wireless. Don't worry, will still expect adb keys.
2. `010-copyInternalStorageContent` - copies all files in `skeleton/internalStorage` to the internal storage via rsync (fast, can do gigabytes. Lineage provides rsync, see the script how it works if you like that. But as its rather complicated we use the sshd termux rsync later for backups)
3. `100-grabDomainED25519CACerts` - this is not optimal yet or standarized RFC, but it asks the local DNS for the TXT-Records of self-signed ED25519-Certs for a set list of hosts (ca. ldap. and vpn.) then saves these to the device on `/sdcard/certs/` for use in OpenVPN and OpenLDAP. See the script for details on how to publish self-signed ED25519 CAs/Certs in your domain using opnsense or openwrt and a certs.webserver

4. `200-openvpnConfig` - copying all files from `skeleton/openvpn` to `/sdcard/openvpn`. You find a generic profile.ovpn with comments on how to do it there.
5. `201-openvpnDeviceCerts` - expects an easy-rsa style PKI-directory in `openvpnPKI/`, then copies the device fqdn cert from f.e. `openvpnPKI/private/$devicename.domain.tld.key` and `openvpnPKI/issued/$devicename.domain.tld.crt` to `/sdcard/openvpn/device.key`/`crt`  - the files are fixed called device.crt and device.key so you can apply a general profile across the fleet. If a ca.domain.tld record is found via DNS-TXT it will be copied to ca.crt.

6. `300-termuxBasicSetup` - Installs the normal repository (deb https://packages.termux.dev is in Germany, Falkenstein) and some basic packages (see script)
7. `310-termuxSkeleton` - copies the content of `skeleton/termux` into the termux home directory.
8. `320-termuxDomainSetup` - if found in skeleton/termux, runs domainSetup.sh on the device via termux. This installs some packages, so take a look!
9. `330-termuxBootSSHD` - makes sure sshd is running after a restart, starts it manually for domainProvisioning and checks if the port is open.
10. `340-termuxSetupExternalSDPath` - adds a symlink "externalsd" in the termux' home to the external sd. Note that this will adb root create a symlink to the UUID that you can only remove or change as root, so make sure the externalsd path is kinda fixed (see "Useful Stuff")

7. `500-skeletonApps` - Installs all apps in skeleton/apps. See the caption about manually backing up and restoring single apps. This can be used to set the default input keyboard f.e.



The device is now ready to hand over to the user for further initial Setup and restore.

# 👶 $\color{green}{\textbf{User}}$ : for a specific device -> user

The user needs an ed25519-key in .ssh. You can create another `id_ed25519_android` called key which also gets added and allows for a second key which is only used for the android device and can thus be nopass (great for autosync)

You don't need to have working adb keys, but ofc can just connect to the device and allow the users adb keys.

## 🧺 1 -> 1 Morph - User-provision the device

Run `userProvision.sh devicename.domain.tld user@domain.tld (0)`

This links the device to the user 0 on the device (Owner). 👥 You can omit the multiuser-id, it will be 0 as default.

🌳 LDAP-Support: You can run this as the domainadmin if you have ldapconfig.ini set up to lookup UID, GID and HOME of the user. The script will set permissions correctly in the users home, so its safe to do this as the Domain-Admin without the user present. All local backups and config go to $LDAPHOME/.android/devices/$deviceName or simply ~/.android/devices/$devicename.

The script then starts all user-tasks-script in skeleton/userTasksScripts:

1. `001-userHomeAndroidSkeleton` - copies skeleton/userHome contents like backup.sh and restore.sh scripts to the users home/.android folder. The scripts provide basic backup and restore for the last 3 backups.
2. `005-userHomeAndroidDeviceFolder` - creates the devicefolder under users home/.android/devices and copies the applist.example to applist (picked up by backup.sh)
3. `010-installInputmethodPreferences` if found, copies `skeleton/com.android.inputmethod.latin_preferences.xml` to `/data/user_de/$MULTIUSERID/com.android.inputmethod.latin/shared_prefs/` to save you the resetup of the soft-keyboard ⌨️.
4. `100-setupExternalStorage` expects termux to work. This looks for the UUID of the 💾 external SD (f.e. `/storage/1234-0512`) and symlinks it to `/data/data/com.termux/files/home/externalsd` - all backup scripts can use this path for backups / syncing of public shares without having to know the UUID in /storage. Do not sync userdata to the externalsd without 🐆 LUKS!
5. `300-termuxSetupSSHKeys` if found, adds the users `.ssh/id_ed25519.pub` and `.ssh/id_ed25519_android.pub` to `/data/data/com.termux/files/home/.ssh/authorized_keys`
6. `350-termuxComfortWatchDogCamera` - 📸 Installs the comfort camera addon. This works by creating an ssh-key on the device and allowing it to upload photos directly to the users Pictures/Camera folder (and nothing else!). Uses an inotify-watch started at boot, so is always available and lightning-fast instant!
7. `400-davx5` - sets all permissions for DAVx5 already and stops nagging the user for donations until 2100-01-01
8. `410-davx5-autodiscovery` - if autodiscovery (see useful stuff) works, adds the useraccount to davx5. You can skip this if the user is not present to type it in. RN you still have to click "Login" and enable the carddav/caldav sync - its the closest i could get it to work for now, sorry.

# Provided userspace-scripts in ~/.android

Still work in progress. Data gets backupped but restoring works only for userfriendly apps. Ill still have to work around vendors not really wanting us to backup data lol - use with caution. You can use swiftbackup and just do a local backup, sync the 16char folder, but even those solutions did not get my ecovacs app correctly restored.

If an app wont restore from user_de and /data/data you should assume the vendor does not like you and look for alternatives.

- run `backup.sh` or have a systemd timer do it. This will connect to all devices via ADB wireless and pull backups (apk + data without caches or no_backup).

- example `sync.sh` to show you how to sync via termux ssh and rsync to the internal storage or external sd. You have to provide the user_id termux is running as for ssh-login to work, you can look it up in termux with `id`

This script actually works flawlessly and syncs at 50MB/sec over VPN or Wifi to my external SD cards.

- If needed use `restore.sh` to restore a single app with `restore.sh device.domain.tld tld.package.name` You can just copy the apks and appData between the 3 last backups and devices if need arises or use this as a template to sync app data from one device to another

👑 You're done! Enjoy your usable device(s)! 🎮

# Useful stuff

## 💾 Static path for SD-Cards

If you want the users SD-Card to be found in a fixed path you can use exfatlabel from exfatprogs to label the card with a fixed UUID like this:

    $sdcardDevicePart is f.e. /dev/sdb1 or /dev/mmbblk0p1 

    root@linux:~# apt install exfatprogs 
    root@linux:~# exfatlabel /dev/$sdcardDevicePart 512GB-SD
    root@linux:~# exfatlabel /dev/$sdcardDevicePart -i 0x12340512
    root@linux:~# lsblk --fs
    NAME   FSTYPE FSVER LABEL UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
    sdb                                                                           
    └─sdb1 exfat  1.0   512GB-SD 1234-0512                                           
                                                         
    
This will set the drives label NAME to "512GB-SD" and the UUID to 1234-0512. I recommend using the uid of the user the device will be provisioned to as the first part and the GB-size as the second.

You can then access the external-sd in a reproducible manner, like `/storage/1234-0512` on the phone. Also domainTask `340-termuxSetupExternalSDPath` will pick this up and use it for the symlink "externalsd" in termux' users home.

## Autoprovision your own apps

The workflow to add an app is usually the same, just `adb shell pm install` the apk

### Permissions

To not nag users with permissions, you can start the app and while it asks for permissions

    adb shell dumpsys package tld.package.name | grep "requested permissions:" -A 100 > before

allow the permission on the device

    adb shell dumpsys package tld.package.name | grep "requested permissions:" -A 100 > after

then just diff those with `diff before after`

you can see all permissions granted and for the autoprovisioning add

    adb shell pm grant com.termux namespace.permission.PERMISSION

Some battery savings and autostart work differently. Whitelist apps to run while idling:

    adb shell dumpsys deviceidle whitelist +com.termux

This is a per-user setting, allows autostart:

    adb shell settings put secure startup_whitelist at.bitfire.davdroid

### overwriting stuff in /data/data/tld.package.name

If you change / push settings.xml in /data/data/tld.package.name and the app crashes check if the u0_a123 uid is correct and run restorecon on files for SELinux-context to work. There is a little helper script in /functions to give you the uid for a tld.package.name

Remember `restorecon -R` to simply fix a whole folder will NOT work on android (and not even tell you about that), you HAVE to explicitly restorecon any file you changed. If you need larger work consider su -c as the apps user.

## Radicale CalDAV / CardDAV Auto-discovery

Radicale offers the .wellknown path already, "simply" add this to your nameserver:

    _caldavs._tcp.domain.tld.	3600	IN	SRV	10 100 5232 dav.domain.tld.
    _carddavs._tcp.domain.tld.	3600	IN	SRV	10 100 5232 dav.domain.tld.

Sadly nowadays all routers and firewall seem to discourage you doing this lol.

In OpenWRT you can add custom records in /etc/dnsmasq.conf with srv-host (file is commented)

    # Change the following lines if you want dnsmasq to serve SRV
    # records.
    # You may add multiple srv-host lines.
    # The fields are <name>,<target>,<port>,<priority>,<weight>

    # A SRV record sending LDAP for the example.com domain to
    # ldapserver.example.com port 289
    #srv-host=_ldap._tcp.example.com,ldapserver.example.com,389

    # Two SRV records for LDAP, each with different priorities
    #srv-host=_ldap._tcp.example.com,ldapserver.example.com,389,1
    #srv-host=_ldap._tcp.example.com,ldapserver.example.com,389,2

    # CalDAV/CardDAV
    srv-host=_caldavs._tcp.domain.tld.,dav.domain.tld,5232,10,100
    srv-host=_carddavs._tcp.domain.tld.,dav.domain.tld,5232,10,100

In OpnSense if you use Unbound, there is a custom repository for a plugin called os-unboundcustom-maxit

https://www.routerperformance.net/opnsense-repo/

Install it and add local-data like:

    server: 
    local-data: "_caldavs._tcp.domain.tld. 3600 IN SRV 10 100 5232 dav.domain.tld."
    local-data: "_carddavs._tcp.domain.tld. 3600 IN SRV 10 100 5232 dav.domain.tld."

This also allows the needed TXT-Records for ED25519-CA-Download

<!--

# Addons that i will do later but forget if not here

## Comfort Addons i do with a custom sync for now:

- Script to inotify-watch the DCIM folder and sync all photos to the users home. This expects a homes. host but you can easily modify the script. This could be done now as i

## Security Addons that will need a new kernel compiled on the devices:

- Setups for termux to use a LUKS-encrypted container on the SD card. This way you can lose the phone safely without an attacker knowing who it belongs to. You revoke the openvpn-keys, remote erase if you still can and sleep well.

- There is also the possibility to mount the users NFS-kerberized home onto the device if you have fun compiling the kernel again. This is recommended for all personal files so they will not be stored on the device in any way. There is no GSSAPI SSO support for now, sorry, you will have to login as the user.

-->