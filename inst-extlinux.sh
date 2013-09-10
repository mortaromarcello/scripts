#!/usr/bin/env bash
#
#

if [ $UID != 0 ]; then
	echo "Devi essere root per eseguire questo script."
	exit
fi

if [ -z $1 ] & [ -z $2 ]; then
	echo -e "Uso: ${0} /dev/sd(x) /path/to/mount/\n\n \
/dev/sd(x): disco dove installare extlinux;\n \
/path/to/mount/: directory dove verrà montata la prima partizione ext2;\n"
	exit
fi

#-----------------------------------------------------------------------
echo -e "Posso cancellare la pennetta e ricreare la partizione. Sei d'accordo (s/n)?"
read sn
if [ ${sn} = "s" ]; then
	echo "Sovrascrivo la tabella delle partizioni."
	parted -s ${1} mktable msdos
	echo "Creo la partizione primaria fat32 alla massima dimensione."
	echo -e ",4096,83,*\n,,83" | sfdisk -u M ${1}
	#echo -e "mkpart primary fat32 1 -1\nset 1 boot on\nq\n" | parted ${1}
	echo "Formatto la partizione."
	mke2fs -t ext2 ${1}1
	mke2fs -t ext4 ${1}2
	e2label {1}2 persistence
	tune2fs -i 0 ${1}1
	tune2fs -i 0 ${1}2
fi
#-----------------------------------------------------------------------
[[ ! -d /tmp/syslinux ]] && mkdir -p /tmp/syslinux; cd /tmp/syslinux
wget https://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-5.10.tar.bz2
tar xfv syslinux-5.10.tar.bz2
cd syslinux-5.10
make
if [ -z ${?} ]; then
	echo "Errore compilando syslinux"
	rm -R -f -v /tmp/syslinux
	exit
fi
mount ${1}1 ${2} < /dev/null 2>&1
if [ -z ${?} ]; then
	echo "Errore montando ${1}1 in ${2}"
	rm -R -f -v /tmp/syslinux
	exit
fi
if [ ! -d ${2}/boot/extlinux ]; then
	echo "Creo la directory ${2}/boot/extlinux (premere Invio o Crtl-c per uscire)"
	read
	mkdir -p ${2}/boot/extlinux
fi
echo "Copio mbr in ${1} (premere Invio o Crtl-c per uscire)"
read
cat mbr/mbr.bin > ${1}
echo "Installo extlinux in ${1}1 (premere Invio o Crtl-c per uscire)"
read
extlinux/extlinux --install ${2}/boot/extlinux
cp com32/chain/chain.c32 ${2}/boot/extlinux
cp com32/modules/config.c32 ${2}/boot/extlinux
cp com32/modules/reboot.c32 ${2}/boot/extlinux
cp com32/hdt/hdt.c32 ${2}/boot/extlinux
cp com32/lib/libcom32.c32 ${2}/boot/extlinux
cp com32/libutil/libutil.c32 ${2}/boot/extlinux
cp com32/menu/menu.c32 ${2}/boot/extlinux
cp com32/menu/vesamenu.c32 ${2}/boot/extlinux
cp memdisk/memdisk ${2}/boot/extlinux
if [ ! -d ${2}/menus/extlinux ]; then
	echo "Creo la directory ${2}/menus/extlinux (premere Invio o Crtl-c per uscire)"
	read
	mkdir -p ${2}/menus/extlinux
fi
cat >${2}/boot/extlinux/extlinux.conf <<EOF
DEFAULT main

LABEL main
COM32 /boot/extlinux/menu.c32
APPEND /menus/extlinux/main.cfg
EOF
cat >${2}/menus/extlinux/defaults.cfg <<EOF
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
cat >${2}/menus/extlinux/main.cfg <<EOF
MENU INCLUDE /menus/extlinux/defaults.cfg
UI /boot/extlinux/menu.c32

DEFAULT label

LABEL label
MENU LABEL label

MENU SEPARATOR

LABEL -
MENU LABEL Reboot
TEXT HELP
 Reboot the PC.
ENDTEXT
COM32 /boot/extlinux/reboot.c32
EOF
umount $2
rm -R -f -v /tmp/syslinux
echo "Fatto!"

