#!/usr/bin/env bash
# Created: 2018-03-23
# Usage: disk-duplicator.sh
# Must be run as root. Will wipe all disks on the system other than sda.

#Unmount all filesystems under /media
function umountMedia {
	echo -n Unmounting media...
	mount | grep "/media" | awk -F " " '{print $1}' | parallel --will-cite umount
	sync
	echo done.
}

umountMedia

echo Started writing media at $(date -Is).

# Find all drives except sda. Pipe to Parallel.
find /dev/ -regex "/dev/sd[a-z]*" ! -name "sda" -print0 | parallel --will-cite -P30 -n1 -0 cat disk.img '>' {.}

echo Write complete at $(date -Is).

umountMedia

echo Batch complete!