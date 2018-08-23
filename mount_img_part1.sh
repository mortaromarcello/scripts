#!/usr/bin/env bash

if [ $UID != 0 ]; then
	echo "Solo per root."
	exit
fi
if [ ! $1 ] || [ ! $2 ]; then
	echo "Uso: $0 <disco immagine> <directory da montare>"
	exit
fi
LOOP=$(losetup -f)
STARTP1=$(parted $LOOP unit B p| awk 'FNR > 5 && $2 ~ /[0-9]/ {print $2}')
if [ $STARTP1 ]; then
	STARTP1=$(echo ${STARTP1:0:${#STARTP1} - 1})
else
	exit
fi
losetup -o ${STARTP1} $LOOP ${1}
mount ${LOOP} ${2}

