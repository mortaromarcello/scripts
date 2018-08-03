#!/usr/bin/env bash

if [ $UID != 0 ]; then
    echo "Solo per root."
    exit
fi
if [ ! $1 ] || [ ! $2 ] || [ ! $3 ]; then
    echo "Uso: $0 <disco immagine> <directory da montare> <numero partizione>"
    exit
fi
LOOP=$(losetup -f)
IMG=$1
DIR=$2
N_PART=$3
echo $IMG $DIR $N_PART
LINE=$(parted $IMG unit B p | awk -v var="$N_PART" 'FNR > 5 && $1 == var {print}')
echo $LINE
STARTP=$(echo $LINE | awk '$2 ~ /[0-9]/ {print $2}')
echo $STARTP
if [ -n $STARTP ]; then
    STARTP=$(echo ${STARTP:0:${#STARTP} - 1})
    echo $STARTP
else
    exit
fi
losetup -o ${STARTP} $LOOP $IMG
mount ${LOOP} $DIR
