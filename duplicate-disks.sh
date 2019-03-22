#!/usr/bin/env bash
# Created: 2018-03-23
# Usage: disk-duplicator.sh
# Must be run as root. Will wipe all disks on the system other than root.

set -uo pipefail

while getopts "hf:s:" opt; do
	case ${opt} in
		f ) #Source disk image
			export file=${OPTARG}
			;;
		s ) # sha512sum
			export sha512=${OPTARG}
			;;
		h | * ) 
			echo "Usage disk-duplicator.sh -s sha512sum -f source.img"
			;;
	esac
done

#Unmount all filesystems under /media
function umountMedia {
	echo -n Unmounting media...
	mount | grep "/media" | cut -f 1 -d " " | parallel --will-cite umount
	sync
	echo done.
}

function writeMedia {
	cat "${file}" > ${1}
	if [[ ${?} != "0" ]]; then
		echo -e "${RED} Error writing ${1}. Status ${?}.${NC}"
		exit 1
	fi
	
	resultSha512=`head --bytes=${bytes} ${1} | sha512sum -b | cut -f 1 -d " "`
	if [[ "${sha512}" == "${resultSha512}" ]]; then
		echo "Successfully verified ${1}"
	else
		echo -e "${RED}Verification failed on ${1}${NC}"
	fi
}

function getNonRootDisks {
	rootDisk=$(findmnt -o Source / | egrep -o "sd[a-z]|nvme[0-9]n[0-9]")
	find /dev/ -regex "/dev/sd[a-z]*" ! -name $rootDisk
}

export -f writeMedia
export RED='\033[0;31m'
export NC='\033[0m'

umountMedia

# Get count of disks for comparison later.
startCount=`getNonRootDisks | wc -l`

echo Started writing ${startCount} disks at $(date -Is).

# Get size of source image in bytes
export bytes=`du -b ${file}| cut -f 1`

# Find all drives except sda. Pipe to Parallel.
getNonRootDisks | parallel --will-cite -P30 -n1 writeMedia {}

endCount=`getNonRootDisks | wc -l`

echo Writes complete at $(date -Is).

if [[ ${startCount} == ${endCount} ]]; then
	echo Started with $startCount disks, ended with $endCount
else
	echo -e "${RED}Error: Started with ${startCount} disks, ended with ${endCount}.${NC}"
fi

umountMedia

# Send a terminal bell character.
tput bel

echo Batch complete!
