#!/data/data/com.termux/files/usr/bin/bash

# user should have
# command="scp -v -t /homes/richard/Pictures/Camera",no-pty,no-X11-forwarding ssh-ed25519 fjdkslfajösdlkfaj user@machine
# in his .ssh/authorized keys

# Directory to watch
WATCH_DIR="/sdcard/DCIM/Camera"

# gets set in autoprovisioning
USER=user
DOMAIN=domain.tld

# Destination directory (NFS or SSH server directory)
REMOTE_DIR="${USER}@homes.${DOMAIN}:~/Pictures/Camera/" # gets overwritten anyways

# SSH key for authentication
SSH_KEY="$HOME/.ssh/id_ed25519_camerawatchdog"

# Dont run watches if no key is found, key gets set in userprovisioning
if [ ! -f "$SSH_KEY" ]; then
    echo "Key not found, exiting"
    exit 0
fi

# This sets up watches for the folder. Some apps will create temporary files. We wait for 2 seconds, then push all pictures from the last 2 hours sorted date DESC
while true; do
    inotifywait -m -e create,moved_to --format '%w%f' "$WATCH_DIR" |
    while read filename; do
        # Skip .pending files
        if [[ "$filename" == *.pending* ]]; then
            echo "Skipping pending $filename"
            continue
        fi

        echo $filename

        # make sure to use -O or it may try sftp-server, not scp
        scp -O -v -i "$SSH_KEY" "$filename" "$REMOTE_DIR"

    done
done