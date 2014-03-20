#!/usr/bin/env bash

if [ $UID != 0 ]; then
	echo "Devi essere root per eseguire questo script."
	exit
fi
if [ -z $1 ]; then
	echo -e "Uso: ${0} /path/drive\n \
/path/drive:hard disk virtuale di qemu"
	exit
fi
echo -e "Attenzione!!!! Se la pendrive è già montata dovete assolutamente smontarla!!!\n(Premere Invio o Ctrl-c per uscire)"
read
ID=
CONT=0
DEV=$(lsusb -t |grep usb-storage|awk '/Dev/ {print $5}'|awk 'BEGIN{FS=","} {print $1}')
for i in $DEV; do
	ID[CONT]=$(lsusb -s $i|awk '{print $6}')
	CONT=$CONT+1
done
if [ -z "${ID}" ]; then
	echo "non c'è nessuna pendrive. Esco"
	exit
fi
LIM=$(expr ${#ID[@]} - 1)
for i in $(seq 0 $LIM); do
	echo "Premi ${i} se vuoi usare questo device:${ID[$i]}"
done
read input_var
echo $input_var

if [ ! "${input_var//[0-9]*}" = "" ]; then
	echo "Devi digitare un numero."
	exit
fi
if [ "$input_var" -gt "$LIM" ]; then
	echo "Fuori range."
	exit
fi

if [ ! -e ${1} ]; then
	echo "${1} non esiste. Vuoi creare un disco virtuale con questo nome (s/n)?"
	read sn
	if [ $sn = "s" ]; then
		echo "Dimensione (in Mbyte)?"
		read size
		if [ ! "${size//[0-9]*}" = "" ]; then
			echo "Devi digitare un numero."
			exit
		fi
		size="${size}M"
		qemu-img create -f qcow2 ${1} $size
		if [ $? -ne 0 ]; then
			echo "Qualcosa è andato storto. Esco"
			exit
		fi
	else
		echo "Non posso proseguire."
		exit
	fi
fi

qemu -machine type=pc,accel=kvm:xen:tcg -m 512 -drive file=${1},if=ide,media=disk -usb -usbdevice host:${ID[$input_var]} -boot menu=on
