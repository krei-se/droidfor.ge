# 🤖 Droidfor.ge 🩻

### Bend your Androids juuust right

- This is still in active development
- Visit <a href="https://krei.se">Krei.se</a> for updates and how to build a free managed domain (german)

### Auto provisioning and Backup/Restore solution for android fleet devices.

Built for Phones with unlockable bootloaders, thus rootable o-O-o lineage devices, also SD-Cards and A/B Slot Support (Motorola and Sony mostly)

- $\color{red}{\textbf{Domain}}$: An 👨‍🏭 Admin sets up a 🩻 skeleton settings template via a 🥼 Vanilla Device for the Managed Domain.

- $\color{blue}{\textbf{Machine}}$: The 👨‍🏭 Admin integrates each device into the Managed Domain.

- $\color{green}{\textbf{User}}$: All 👶 Users set up their fresh device once, backup is done transparent via the nfs home file server or manually in the userspace session.

Turns your android phones into rooted, but secure and usuable domain clients. No Clouds!

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

## 🩻 0 -> 1 Initial - Customize the skeleton

On the now 🩻 skeleton device you can customize ⚙️ settings you want on all devices in the domain / fleet.

Run `createSkeletonSettingsDiff.sh` - this script diffs your settings into `skeleton/settings[namespace]` and removes some settings that i noticed will change during setup (screen brightness, charging time, etc.)

These scripts take no arguments, so make sure it's the only device attached.

⌨️ It will ask if you want the input method captured too and save this to `skeleton/com.android.inputmethod.latin_preferences.xml` for a later task to pick up. Note this is technically a user-profile setting.

### Notes on stuff i will solve later when needed

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
3. `100-grabDomainED25519CACerts` - this is not optimal yet or standarized RFC, but it asks the local DNS for the TXT-Records of self-signed ED25519-CAs for a set list of hosts (ca. ldap. and vpn.) then saves these to the device on `/sdcard/certs/` for use in OpenVPN and OpenLDAP. See the script for details how to publish self-signed ED25519 CAs in your domain using opnsense or openwrt and a certs.webserver

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

The user needs an ed25519-key in .ssh. You don't need to have working adb keys, but ofc can just connect to the device and allow the users adb keys.

## 🧺 1 -> 1 Morph - User-provision the device

Run `userProvision.sh devicename.domain.tld user@domain.tld (0)`

This links the device to the user 0 on the device (Owner). 👥 You can omit the multiuser-id, it will be 0 as default.

🌳 LDAP-Support: You can run this as the domainadmin if you have ldapconfig.ini set up to lookup UID, GID and HOME of the user. The script will set permissions correctly, so its safe to do this as the Domain-Admin without the user present. All local backups and config go to $LDAPHOME/.android/devices/$deviceName or simply ~/.android/devices/$devicename.

The script then starts all user-tasks-script in skeleton/userTasksScripts:

1. `010-installInputmethodPreferences.sh` if found, copies `skeleton/com.android.inputmethod.latin_preferences.xml` to `/data/user_de/$MULTIUSERID/com.android.inputmethod.latin/shared_prefs/` to save you the resetup of the soft-keyboard ⌨️.
2. `100-setupExternalStorage.sh` expects termux to work. This looks for the UUID of the 💾 external SD (f.e. `/storage/1234-0512`) and saves it into the users device config so all backup scripts locally can know the path for backups / syncing of public shares. Do not sync userdata to the externalsd without 🐆 LUKS!
3. `300-termuxSetupSSHKeys` if found, adds the users `.ssh/id_ed25519.pub` to `/data/data/com.termux/files/home/.ssh/authorized_keys`




You're done! Enjoy your usable device!

# Useful stuff

## 💾 Static path for SD-Cards

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

You can then access the external-sd in a reproducible manner, like `/storage/1234-0512` on the phone. Also domainTask `340-termuxSetupExternalSDPath` will pick this up and use it for the symlink "externalsd" in termux' users home.

## Security Addons:

- I provide setups for termux to use a LUKS-encrypted container on the SD card. This way you can lose the phone safely without an attacker knowing who it belongs to. You revoke the openvpn-keys, remote erase if you still can and sleep well.

- There is also the possibility to simply mount the users NFS-kerberized home onto the device. This is recommended for all personal files so they will not be stored on the device in any way. There is no GSSAPI SSO support for now, sorry, you will have to login as the user.

## Comfort Addons (i will do later lol):

- Script to inotify-watch the DCIM folder and sync all photos to the users home. This expects a homes. host but you can easily modify the script.
