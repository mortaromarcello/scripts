#!/usr/bin/env bash
if [ -z $1 ]; then 
	echo "Inserire la directory di destinazione."
	exit
fi

if [ ${UID} != 0 ]; then
	echo "Devi essere root per eseguire questo script."
	exit
fi

INST_ROOT_DIRECTORY=$1
#EXCLUDE_PATTERNS="'/etc/fstab' '/dev/*\",\"/proc/*\",\"/sys/*\",\"/tmp/*\",\"/run/*\",\"/mnt/*\",\"/media/*\",\"/lost+found\",\"/home/*\"}"

function copy_root() {
	rsync -aAXv --exclude /etc/fstab --exclude '/dev/*' --exclude '/proc/*' --exclude '/sys/*' --exclude '/tmp/
	' --exclude '/run/*' --exclude '/media/*' --exclude '/lost+found/' --exclude '/home/*' / ${INST_ROOT_DIRECTORY}
}

copy_root
#rm ./PATTERNS
