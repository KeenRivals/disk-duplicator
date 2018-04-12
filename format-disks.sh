#!/usr/bin/env bash
# Created: 2018-03-27
# Usage: format-disks.sh
# Must be run as root. Will wipe all disks on the system other than sda and format them to ntfs.

#Unmount all filesystems under /media
function umountMedia {
	echo -n Unmounting media...
	mount | grep "/media" | awk -F " " '{print $1}' | parallel --will-cite umount
	sync
	echo done.
}

# Create a gpt layout on a disk, one partition, and format it ntfs.
function formatMedia {
	gdisk ${1} <<EOF
o
y
n



0700
w
y
EOF
	sleep 2
	partprobe ${1}
	sleep 2
	mkfs.ntfs -Q -I ${1}1
}

export -f formatMedia

umountMedia

echo Started writing media at $(date -Is).

#Find which drive is mounted as root.
rootDisk=$(findmnt -o Source / | egrep -o "sd[a-z]")

# Find all drives except sda. Pipe to Parallel.
find /dev/ -regex "/dev/sd[a-z]*" ! -name $rootDisk -print0 | parallel --will-cite -P30 -n1 -0 formatMedia {.}

echo Write complete at $(date -Is).

umountMedia

echo Batch complete!
