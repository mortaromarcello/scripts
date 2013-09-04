#!/usr/bin/env bash

if [ -z ${1} ] & [ -z ${2} ] & [ -z ${3} ]; then
	echo "Uso:$0 <disco.img> <Mbytes> </percorso/di/montaggio"
	exit
fi
DIR_MOUNT=${3}
if [ ${DIR_MOUNT:${#DIR_MOUNT}-1} = "/" ]; then 			# se l'ultimo carattere è /
	DIR_MOUNT=${DIR_MOUNT:0:${#DIR_MOUNT}-1} 				#allora lo toglie
fi
LOOP1=$(losetup -f)											#trova il primo loop libero
dd if=/dev/zero of=${1} bs=1k count=0 seek=$[1024*${2}]		#crea l'immagine
losetup ${LOOP1} ${1}										#crea il loop dell'immmagine
parted -s ${LOOP1} mklabel msdos							#crea tabella partizioni
#crea partizione primaria fat32 capacità massima con flag boot
echo ",,c,*" | sfdisk -D ${LOOP1} > /dev/null 2>&1
#echo -e "mkpart primary fat32 1 -1\nset 1 boot on\nq\n" | parted ${LOOP1}
#copia mbr
dd bs=440 conv=notrunc count=1 if=/usr/lib/syslinux/mbr.bin of=${LOOP1}
#start=l'offset della partizione con parted
start=$(parted ${LOOP1} unit B p|awk 'FNR > 5 && $2 ~ /[0-9]/ {print $2}')
if [ -n $start ]; then										#se $start non è vuota
	start=$(echo ${start:0:${#start}-1})					#toglie l'ultima lettera (B)
else
	echo "errore"											#altrimenti esce
	exit
fi
LOOP2=$(losetup -f)
losetup -o ${start} ${LOOP2} ${1}							#crea loop per la partizione
mkdosfs $LOOP2												#formatta partizione
mount -t vfat ${LOOP2} ${DIR_MOUNT}							#monta partizione
mkdir -p ${DIR_MOUNT}/boot/syslinux							#crea directory
syslinux -d /boot/syslinux -i ${LOOP2}						#installa syslinux
for i in chain.c32 config.c32 hdt.c32 libcom32.c32 libutil.c32 memdisk menu.c32 reboot.c32 vesamenu.c32 whichsys.c32; do
	cp -f /usr/lib/syslinux/$i ${DIR_MOUNT}/boot/syslinux/
done
mkdir -p ${DIR_MOUNT}/menus/syslinux
cat >${DIR_MOUNT}/boot/syslinux/syslinux.cfg <<EOF
DEFAULT main

LABEL main
COM32 /boot/syslinux/menu.c32
APPEND /menus/syslinux/main.cfg
EOF
cat >${DIR_MOUNT}/menus/syslinux/defaults.cfg <<EOF
MENU TITLE Title

MENU MARGIN 0
MENU ROWS -9
MENU TABMSG
MENU TABMSGROW -3
MENU CMDLINEROW -3
MENU HELPMSGROW -4
MENU HELPMSGENDROW -1

MENU COLOR SCREEN 37;40
MENU COLOR BORDER 34;40
MENU COLOR TITLE 1;33;40
MENU COLOR SCROLLBAR 34;46
MENU COLOR SEL 30;47
MENU COLOR UNSEL 36;40
MENU COLOR CMDMARK 37;40
MENU COLOR CMDLINE 37;40
MENU COLOR TABMSG 37;40
MENU COLOR DISABLED 37;40
MENU COLOR HELP 32;40
EOF
cat >${DIR_MOUNT}/menus/syslinux/main.cfg <<EOF
MENU INCLUDE /menus/syslinux/defaults.cfg
UI /boot/syslinux/menu.c32

DEFAULT label

LABEL label
MENU LABEL label

MENU SEPARATOR

LABEL -
MENU LABEL Reboot
TEXT HELP
 Reboot the PC.
ENDTEXT
COM32 /boot/syslinux/reboot.c32
EOF
umount ${DIR_MOUNT}
losetup -d $LOOP1
losetup -d $LOOP2
