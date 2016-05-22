#!/usr/bin/env bash
#
# per distro debian. Il pacchetto syslinux deve essere già installato nel sistema.
#

SYSLINUX_DIR="/usr/lib/syslinux/modules/bios"
SYSLINUX_INST="/boot/syslinux"
MBR_DIR="/usr/lib/syslinux/mbr"
SIZE_PRIMARY_PART=4096M
TYPE_PART=ext4
DEVICE_USB=
PATH_TO_MOUNT=

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
Crea una live Devuan
  -d | --device-usb <device>             :device usb.
  -h | --help                            :Stampa questa messaggio.
  -p | --path-to-mount                   :path della directory di montaggio.
  -s | --path-to-install-syslinux <dir>  :path di installazione di syslinux.
  -n | --size-primary-part <size>        :dimensione partizione primaria in MB
  -t | --type-partition <type>           :tipo partizione (ext4 default).
"
}

function check_script() {
	check_root
	if [ -z $DEVICE_USB ] && [ -z $PATH_TO_MOUNT ]; then
		help
		exit
	fi
	echo "device usb $DEVICE_USB"
	echo "path to mount $PATH_TO_MOUNT"
	echo "syslinux install path $SYSLINUX_INST"
	echo "size primary partition $SIZE_PRIMARY_PART"
	echo "tipo partizione $TYPE_PART"
	echo "Script verificato. OK."
}


function create_partitions() {
	echo "Sovrascrivo la tabella delle partizioni."
	parted -s ${DEVICE_USB} mktable msdos
	read -p "Creo la partizione primaria fat32 e la partizione secondaria ext4 (premere Invio o Crtl-c per uscire)"
	sfdisk ${DEVICE_USB} << EOF
	,${SIZE_PRIMARY_PART},c,*
	;
EOF
	
	#echo -e ",4096,c,*\n,,83" | sfdisk -D -u M ${1}
	read -p "Formatto la prima partizione. (premere Invio o Crtl-c per uscire)"
	#echo -e "mkpart primary fat32 1 -1\nset 1 boot on\nq\n" | parted ${1}
	mkdosfs ${DEVICE_USB}1
	read -p "Formatto la seconda partizione. (premere Invio o Crtl-c per uscire)"
	mkfs -t ${TYPE_PART} ${DEVICE_USB}2
	e2label {DEVICE_USB}2 persistence
	tune2fs -i 0 ${DEVICE_USB}2
}

function install_syslinux() {
	if [ -e /usr/bin/syslinux ]; then
		mount -v ${DEVICE_USB}1 ${PATH_TO_MOUNT} </dev/null
		if [ -z ${?} ]; then
			echo "Errore montando ${DEVICE_USB}1 in ${PATH_TO_MOUNT}"
			exit
		fi
		if [ ! -d ${PATH_TO_MOUNT}${SYSLINUX_INST} ]; then
			echo "Creo la directory ${PATH_TO_MOUNT}${SYSLINUX_INST} (premere Invio o Crtl-c per uscire)"
			read
			mkdir -p ${PATH_TO_MOUNT}${SYSLINUX_INST}
		fi
		echo "Copio mbr in ${DEVICE_USB} (premere Invio o Crtl-c per uscire)"
		read
		cat ${MBR_DIR}/mbr.bin > ${DEVICE_USB}
		echo "Installo syslinux in ${DEVICE_USB}1 (premere Invio o Crtl-c per uscire)"
		read
		syslinux --directory ${SYSLINUX_INST} --install ${DEVICE_USB}1
		for i in chain.c32 config.c32 hdt.c32 libcom32.c32 libutil.c32 menu.c32 reboot.c32 vesamenu.c32 whichsys.c32; do
			cp -v ${SYSLINUX_DIR}/$i ${PATH_TO_MOUNT}${SYSLINUX_INST}
		done
		cp -v /usr/lib/syslinux/memdisk ${PATH_TO_MOUNT}${SYSLINUX_INST}
		if [ ! -d ${PATH_TO_MOUNT}/menus/syslinux ]; then
			echo "Creo la directory ${PATH_TO_MOUNT}/menus/syslinux (premere Invio o Crtl-c per uscire)"
			read
			mkdir -p ${PATH_TO_MOUNT}/menus/syslinux
		fi
		cat >${PATH_TO_MOUNT}${SYSLINUX_INST}/syslinux.cfg <<EOF
DEFAULT main

LABEL main
COM32 ${SYSLINUX_INST}/menu.c32
APPEND /menus/syslinux/main.cfg
EOF
		cat >${PATH_TO_MOUNT}/menus/syslinux/defaults.cfg <<EOF
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
		cat >${PATH_TO_MOUNT}/menus/syslinux/main.cfg <<EOF
MENU INCLUDE /menus/syslinux/defaults.cfg
UI ${SYSLINUX_INST}/menu.c32

DEFAULT label

LABEL label
MENU LABEL label

MENU SEPARATOR

LABEL -
MENU LABEL Reboot
TEXT HELP
 Reboot the PC.
ENDTEXT
COM32 ${SYSLINUX_INST}/reboot.c32
EOF
		umount $PATH_TO_MOUNT
		echo "Fatto!"
	else
		echo "syslinux non è installato sul tuo sistema. Esco."
	fi
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
		-h | --help)
			shift
			help
			exit
			;;
		-p | --path-to-mount)
			shift
			PATH_TO_MOUNT=${1}
			;;
		-s | --path-to-install-syslinux)
			shift
			SYSLINUX_INST=${1}
			;;
		-n | --size-primary-part)
			shift
			SIZE_PRIMARY_PART=${1}M
			;;
		-t | --type-partition)
			shift
			TYPE_PART=${1}
			;;
		*)
			shift
			;;
	esac
done

check_script
umount -v ${PATH_TO_MOUNT} ${DEVICE_USB}1
echo -e "Posso cancellare la pennetta e ricreare la partizione. Sei d'accordo (s/n)?"
read sn
if [ ${sn} = "s" ]; then
	create_partitions
fi
install_syslinux
