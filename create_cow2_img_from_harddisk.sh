#!/usr/bin/env bash

if [ $UID != 0 ]; then
    echo "Devi essere root per eseguire questo script."
    exit
fi

if [ ! $(which qemu-img) ]; then
    echo "qemu-img deve essere installato."
    exit -1
fi

echo $1
echo $2
echo $3

if [ ! $1 ] || [ ! $2 ]; then
    echo "Uso: create_cow2_img_from_harddisk.sh </dev/sd(x)> <path_destinazione> <nome immagine>"
    exit -1
fi

if [ ! $3 ]; then
    NOMEFILE=imagedisk
else
    NOMEFILE=$3
fi

qemu-img convert -O qcow2 $1 $2/$NOMEFILE.qcow2

