#!/usr/bin/env bash

if [ $UID != 0 ]; then
    echo "Devi essere root per eseguire questo script."
    exit
fi

if [ ! $1 ] || [ ! $2 ]; then
    echo "Uso: $0 <disco immagine> <device usb>"
    exit
fi

sudo dd if=$1 of=$2 status=progress
