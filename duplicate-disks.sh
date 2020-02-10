#!/usr/bin/env bash
# Created: 2018-03-23
# Usage: disk-duplicator.sh -s sha512sum -f source.img
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
			echo "Usage disk-duplicator.sh -s sha512sum -f source.img" >&2
			;;
	esac
done

#Unmount all filesystems under /media
function umountMedia {
	echo -n Unmounting media... >&2
	mount | grep "/media" | cut -f 1 -d " " | parallel --will-cite umount
	sync
	echo done. >&2
}

function writeMedia {
	cat "${file}" > ${1}
	if [[ ${?} != "0" ]]; then
		echo -e "${RED} Error writing ${1}. Status ${?}.${NC}" >&2
		exit 1
	fi
	
	# Try to read the disk image back twice. My USB drives disconnect sometimes, 
	# which causes head to exit with input/output error. If it succeeds, exit the loop, if not, sleep 30 and try again
	resultSha512=$( verifyMedia ${1} )

	if [[ "${sha512}" == "${resultSha512}" ]]; then
		echo "Successfully verified ${1}" >&2
	else
		echo -e "${RED}Verification failed on ${1}${NC}" >&2
	fi
}

# Return sha512 of the byte range written to the drive. Try to read it three times, sometimes the disk 
# drops and head dies.
function verifyMedia {
	set -uo pipefail
	for i in {1..3}; do
		sleep 30
		sha512=`head --bytes=${bytes} ${1} | sha512sum -b | cut -f 1 -d " "`
		
		# If head & sha512sum were successful, echo the result and escape the loop.
		if [[ ${?} == "0" ]]; then
			break
		fi

		echo -e "${YEL}Reverifying ${1}${NC}" >&2
	done	

	echo $sha512
}

function getNonRootDisks {
	rootDisk=$(findmnt -o Source / | egrep -o "sd[a-z]|nvme[0-9]n[0-9]")
	find /dev/ -regex "/dev/sd[a-z]*" ! -name $rootDisk
}

export -f writeMedia
export -f verifyMedia
export RED='\033[0;31m'
export NC='\033[0m'
export YEL='\e[33m'

umountMedia

# Get count of disks for comparison later.
startCount=`getNonRootDisks | wc -l`

echo Started writing ${startCount} disks at $(date -Is). >&2

# Get size of source image in bytes
export bytes=`du -b ${file}| cut -f 1`

# Find all drives except sda. Pipe to Parallel.
getNonRootDisks | parallel --will-cite -P30 -n1 writeMedia {}

endCount=`getNonRootDisks | wc -l`

echo Writes complete at $(date -Is). >&2

if [[ ${startCount} == ${endCount} ]]; then
	echo Started with $startCount disks, ended with $endCount >&2
else
	echo -e "${RED}Error: Started with ${startCount} disks, ended with ${endCount}.${NC}" >&2
fi

umountMedia

# Send a terminal bell character.
tput bel

echo Batch complete! >&2
