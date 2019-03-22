# Disk Duplicator

Write a disk.img file to multiple targets in parallel. Writes to every disk except the one mounted as root.

**WARNING**: These scripts are super dangerous, and indiscriminately destroy data. It's not recommended to run them on a machine with any data you care about.

# Setup

On your Ubuntu/Debian system:

1. Run ``install.sh`` to install the prereqs.
2. Disable automount: ``gsettings set org.gnome.desktop.media-handling automount false``
3. Depending on what updates were installed, reboot the system.

## Prep

1. Run ``fallocate -dv disk.img`` to make your image sparse. This speeds things up by reducing reads of unnecessary zeros.

# Running

1. Insert your USB drives. If using a hub, make sure they're all powered up and online.
2. Wait a short time (~30s) for the system to detect all of the drives.
3. Run ``duplicate-disks.sh`` as root with the -f argument as a path to the file and -s with a sha512sum of the file.
4. Wait for duplication to complete. Inspect the results for errors.
5. When it's done, wait a short time then remove the disks.

## Troubleshooting Tips 

If you get a non-zero exit code, it's possible that drive came disconnected or is faulty. Faulty drives may show as read-only. Disconnect all drives and reconnect. Try duplicating again.

# Verification

The script verifies the provided sha512 is good but it never hurts to check. Take a few drives from each batch and verify them. For bootable clonezilla images, you can try restoring them to test machines.
