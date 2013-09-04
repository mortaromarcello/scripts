#!/usr/bin/env bash

if [ $UID != 0 ]; then
	echo "Devi essere root per eseguire questo script."
	exit
fi
if [ -z $1 ]; then
	echo -e "Uso: ${0} /path/drive xxxx:xxxx\n \
/path/drive:hard disk virtuale di qemu\n \
xxxx:xxxx: numero identificativo della pendrive (si può leggere tramite il comando 'lsusb')"
	exit
fi
echo -e "Attenzione!!!! Se la pendrive è già montata dovete assolutamente smontarla!!!\n(Premere Invio o Ctrl-c per uscire)"
read

qemu -machine type=pc,accel=kvm:xen:tcg -m 512 -drive file=${1},if=ide,media=disk -usb -usbdevice host:${2} -boot menu=on
