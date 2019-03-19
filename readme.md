# Disk Duplicator

Write a disk.img file to multiple targets in parallel. Writes to every disk except the one mounted as root.

**WARNING**: These scripts are super dangerous, and indiscriminately destroy data. It's not recommended to run them on a machine with any data you care about.

# Setup

On your Ubuntu/Debian system:

1. Run ``install.sh`` to install the prereqs, and enable the PC speaker.
2. Disable automount: ``gsettings set org.gnome.desktop.media-handling automount false``
3. Depending on what updates were installed, reboot the system.

## Prep

1. Put your raw disk image in the same folder as ``duplicate-disks.sh``. Name it ``disk.img``.
2. Run ``fallocate -dv disk.img`` to make the disk image sparse. This speeds things up by reducing reads of unnecessary zeros.

# Running

1. Insert your USB drives. If using a hub, make sure they're all powered up and online.
2. Wait a short time (~30s) for the system to detect all of the drives.
3. Run ``duplicate-disks.sh`` as root within the script's directory.
4. Wait for duplication to complete. Inspect the result of each disk. You want to see status 0.
5. When it's done, wait a short time then remove the disks.

## Troubleshooting Tips 

If you get a non-zero exit code, it's possible that drive came disconnected or is faulty. Faulty drives may show as read-only. Disconnect all drives and reconnect. Try duplicating again.

# Verification

Take a few drives from each batch and verify them. For bootable clonezilla images, you can try restoring them to test machines.

You could also verify the sha512sum of the written image. This isn't heavily tested but worked in a quick test:

1. Get the sha512sum of your disk.img: ``sha512sum -b disk.img``
2. Get the real size of your disk.img in bytes: ``du -b disk.img``
3. Read that number of bytes from the disk and sha512sum it: ``head --bytes=NUM /dev/sdb | sha512sum -b``
4. Compare the result to your original sha512sum.

I elect to not test every single drive in order to get things done more quickly. I test 10% of each batch by doing a clonezilla restore.