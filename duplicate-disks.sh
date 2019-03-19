#!/usr/bin/env bash
# Created: 2018-03-23
# Usage: disk-duplicator.sh
# Must be run as root. Will wipe all disks on the system other than root.

set -uo pipefail

#Unmount all filesystems under /media
function umountMedia {
	echo -n Unmounting media...
	mount | grep "/media" | awk -F " " '{print $1}' | parallel --will-cite umount
	sync
	echo done.
}

function writeMedia {
	cat disk.img > ${1}
	echo Finished writing ${1} with status ${?}.
}

export -f writeMedia

umountMedia

echo Started writing media at $(date -Is).

#Find which drive is mounted as root.
rootDisk=$(findmnt -o Source / | egrep -o "sd[a-z]")

# Find all drives except sda. Pipe to Parallel.
find /dev/ -regex "/dev/sd[a-z]*" ! -name $rootDisk -print0 | parallel --will-cite -P30 -n1 -0 writeMedia {.}

echo Writes complete at $(date -Is).

umountMedia

# Send a terminal bell character.
tput bel

echo Batch complete!