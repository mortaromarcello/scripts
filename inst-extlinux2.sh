#!/usr/bin/env bash
#
# per distro pclinuxos. Il pacchetto extlinux deve essere già installato nel sistema.
#

SYSLINUX_DIR="/usr/lib/syslinux"
EXTLINUX_INST="/boot/extlinux"
EXTLINUX="/usr/sbin/extlinux"
MBR_DIR="/usr/lib/syslinux"
SIZE_PRIMARY_PART=4096M
SIZE_SECONDARY_PART=
TYPE_SECONDARY_PART=L
TYPE_SECONDARY_FS=ext4
DEVICE_USB=
PATH_TO_MOUNT="/mnt"
GRUB_UEFI=0

########################################################################
#                      functions
########################################################################
function check_root() {
	if [ $UID != 0 ]; then
		echo "Devi essere root per eseguire questo script."
		exit
	fi
}

function help() {
	echo -e "
${0} <opzioni>
  -d | --device-usb <device>             :device usb.
  -h | --help                            :Stampa questa messaggio.
  -p | --path-to-mount                   :path della directory di montaggio. (/mnt default)
  -s | --path-to-install-extlinux <dir>  :path di installazione di extlinux. (/boot/syslinux default)
  -n | --size-primary-part <size>        :dimensione partizione primaria in MB
  -o | --size-secondary-part <size>      :dimensione partizione secondaria in MB
  -t | --type-partition <type>           :tipo partizione (ext4 default).
"
}

function check_script() {
	check_root
	if [ -z $DEVICE_USB ]; then
		help
		exit
	fi
	if [ ${TYPE_SECONDARY_FS} = "exfat" ]; then
		TYPE_SECONDARY_PART=7
	elif [ ${TYPE_SECONDARY_FS} = "vfat" ]; then
		TYPE_SECONDARY_PART=c
	fi
	echo "device usb $DEVICE_USB"
	echo "path to mount $PATH_TO_MOUNT"
	echo "extlinux install path $EXTLINUX_INST"
	echo "size primary partition $SIZE_PRIMARY_PART"
	echo "size secondary filesystem $SIZE_SECONDARY_PART"
	echo "tipo di  filesystem partizione secondaria $TYPE_SECONDARY_FS"
	echo "tipo partizione secondaria $TYPE_SECONDARY_PART"
	echo "Script verificato. OK."
}


function create_partitions() {
	echo "Sovrascrivo la tabella delle partizioni."
	parted -s ${DEVICE_USB} mktable msdos
	read -p "Creo la partizione primaria ext2 e la partizione secondaria ${TYPE_SECONDARY_FS} (premere Invio o Crtl-c per uscire)"
	sfdisk ${DEVICE_USB} << EOF
,${SIZE_PRIMARY_PART},c,*
,${SIZE_SECONDARY_PART},${TYPE_SECONDARY_PART}
EOF
	sync && sync
	#echo -e ",4096,c,*\n,,83" | sfdisk -D -u M ${1}
	read -p "Formatto la prima partizione. (premere Invio o Crtl-c per uscire)"
	#echo -e "mkpart primary fat32 1 -1\nset 1 boot on\nq\n" | parted ${1}
	mke2fs -t ext2 ${DEVICE_USB}1
	read -p "Formatto la seconda partizione. (premere Invio o Crtl-c per uscire)"
	if [ ${TYPE_SECONDARY_FS} = "exfat" ] || [ ${TYPE_SECONDARY_FS} = "vfat" ]; then
		mkfs -t ${TYPE_SECONDARY_FS} -n persistence ${DEVICE_USB}2
	else
		mkfs -t ${TYPE_SECONDARY_FS} ${DEVICE_USB}2
	fi
	if [ ${TYPE_SECONDARY_FS} = "ext2" ] || [ ${TYPE_SECONDARY_FS} = "ext3" ] || [ ${TYPE_SECONDARY_FS} = "ext4" ]; then
		e2label ${DEVICE_USB}2 persistence
		tune2fs -i 0 ${DEVICE_USB}2
	fi
}

function install_extlinux() {
	if [ -e $EXTLINUX ]; then
		mount ${DEVICE_USB}1 ${PATH_TO_MOUNT}
		if ! mount | grep ${PATH_TO_MOUNT}; then
			echo "Errore montando ${DEVICE_USB}1 in ${PATH_TO_MOUNT}"
			exit
		fi
		if [ ! -d ${PATH_TO_MOUNT}${EXTLINUX_INST} ]; then
			echo "Creo la directory ${PATH_TO_MOUNT}${EXTLINUX_INST} (premere Invio o Crtl-c per uscire)"
			read
			mkdir -p ${PATH_TO_MOUNT}${EXTLINUX_INST}
		fi
		echo "Copio mbr in ${DEVICE_USB} (premere Invio o Crtl-c per uscire)"
		read
		cat ${MBR_DIR}/mbr.bin > ${DEVICE_USB}
		echo "Installo extlinux in ${PATH_TO_MOUNT}${EXTLINUX_INST} (premere Invio o Crtl-c per uscire)"
		read
		$EXTLINUX --install ${PATH_TO_MOUNT}${EXTLINUX_INST}
		for i in chain.c32 config.c32 hdt.c32 libcom32.c32 libutil.c32 menu.c32 reboot.c32 vesamenu.c32 whichsys.c32; do
			cp -v ${SYSLINUX_DIR}/$i ${PATH_TO_MOUNT}${EXTLINUX_INST}
		done
		cp -v /usr/lib/syslinux/memdisk ${PATH_TO_MOUNT}${EXTLINUX_INST}
		if [ ! -d ${PATH_TO_MOUNT}/menus/extlinux ]; then
			echo "Creo la directory ${PATH_TO_MOUNT}/menus/extlinux (premere Invio o Crtl-c per uscire)"
			read
			mkdir -p ${PATH_TO_MOUNT}/menus/extlinux
		fi
		cat >${PATH_TO_MOUNT}${EXTLINUX_INST}/extlinux.conf <<EOF
DEFAULT main

LABEL main
COM32 ${EXTLINUX_INST}/menu.c32
APPEND /menus/extlinux/main.cfg
EOF
		cat >${PATH_TO_MOUNT}/menus/extlinux/defaults.cfg <<EOF
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
		cat >${PATH_TO_MOUNT}/menus/extlinux/main.cfg <<EOF
MENU INCLUDE /menus/extlinux/defaults.cfg
UI ${EXTLINUX_INST}/menu.c32

DEFAULT label

LABEL label
MENU LABEL label

MENU SEPARATOR

LABEL -
MENU LABEL Reboot
TEXT HELP
 Reboot the PC.
ENDTEXT
COM32 ${EXTLINUX_INST}/reboot.c32
EOF
		if [ ${GRUB_UEFI} = 1 ]; then
			create_grub-uefi
		fi
		sync && sync
		umount -v $PATH_TO_MOUNT
		echo "Fatto!"
	else
		echo "extlinux non è installato sul tuo sistema. Esco."
	fi
}

function create_grub-uefi() {
	git clone http://github.com/mortaromarcello/scripts.git $GIT_DIR/scripts
	cp -av $GIT_DIR/scripts/grub-uefi/* ${PATH_TO_MOUNT}/
}

#-----------------------------------------------------------------------
#-----------------------------------------------------------------------
until [ -z ${1} ]
do
	case ${1} in
		-d | --device-usb)
			shift
			DEVICE_USB=${1}
			;;
		-g | --grub-uefi)
			shift
			GRUB_UEFI=1
			;;
		-h | --help)
			shift
			help
			exit
			;;
		-p | --path-to-mount)
			shift
			PATH_TO_MOUNT=${1}
			;;
		-s | --path-to-install-extlinux)
			shift
			EXTLINUX_INST=${1}
			;;
		-n | --size-primary-part)
			shift
			SIZE_PRIMARY_PART=${1}M
			;;
		-o | --size-secondary-part)
			shift
			SIZE_SECONDARY_PART=${1}M
			;;
		-t | --type-secondary-filesystem)
			shift
			TYPE_SECONDARY_FS=${1}
			;;
		*)
			shift
			;;
	esac
done

check_script
umount -v ${PATH_TO_MOUNT}
umount -v ${DEVICE_USB}1
umount -v ${DEVICE_USB}2
echo -e "Posso cancellare la pennetta e ricreare la partizione. Sei d'accordo (s/n)?"
read sn
if [ ${sn} = "s" ]; then
	create_partitions
fi
install_extlinux
