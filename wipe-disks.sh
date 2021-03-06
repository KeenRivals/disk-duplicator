#!/usr/bin/env bash
# Created: 2018-03-27
# Usage: wipe-disks.sh
# Must be run as root. Will wipe all disks on the system other than sda with zeroes

#Unmount all filesystems under /media
function umountMedia {
	echo -n Unmounting media...
	mount | grep "/media" | awk -F " " '{print $1}' | parallel --will-cite umount
	sync
	echo done.
}

function getNonRootDisks {
	rootDisk=$(findmnt -o Source / | egrep -o "sd[a-z]|nvme[0-9]n[0-9]")
	find /dev/ -regex "/dev/sd[a-z]*" ! -name $rootDisk
}

umountMedia

echo Started writing media at $(date -Is).

# Find all drives except sda. Pipe to Parallel.
getNonRootDisks | parallel --will-cite -P30 -n1 cat /dev/zero '>' {}

echo Write complete at $(date -Is).

umountMedia

# Send a terminal bell character.
tput bel

echo Batch complete!