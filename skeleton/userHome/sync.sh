#!/bin/bash

# Example on how to sync over rsync onto the external sd card


################
#    DEVICE    #
################

#source ~/venvs/betteradbsync/bin/activate

sshkey=~/.ssh/id_ed25519_android

androidUser=u0_a123456 # check this in termux: id tells you the userid
device=devicename # hostname
port=8022
externalsd=/storage/2611-1024 # or use /data/data/com.termux/files/home/externalsd if you have the symlink
internal=/sdcard

# always sync the Camera
rsync $rsyncOptions --update -e "ssh -i $sshkey -p $port" $androidUser@$device:$internal/DCIM/Camera/ ~/Pictures/Camera

# check if the device is in wifi
ping -c 4 -W 5 $device.guest > /dev/null

if [ $? -eq 0 ]; then

    # Inward Sync

    # NewPipe
    rsync $rsyncOptions --update -e "ssh -i $sshkey -p $port" $androidUser@$device:$externalsd/Music/NewPipe/ /srv/nfs/shares/Music/NewPipe

    # Screenshots
    rsync $rsyncOptions --update -e "ssh -i $sshkey -p $port" $androidUser@$device:$internal/Pictures/Screenshots/ ~/Pictures/Screenshots

    # Outward Sync

    # Music
    rsync $rsyncOptions --update --delete -e "ssh -i $sshkey -p $port" /srv/nfs/shares/Music/ $androidUser@$device:$externalsd/Music

    # Books
    rsync $rsyncOptions --update --delete -e "ssh -i $sshkey -p $port" /srv/nfs/shares/Ebooks/ $androidUser@$device:$externalsd/Ebooks

    # Wallpapers
    rsync $rsyncOptions --update --delete -e "ssh -i $sshkey -p $port" ~/Pictures/Wallpapers/ $androidUser@$device:$internal/Pictures/Wallpapers

else

    echo "device not in wlan, only syncing Camera"

fi