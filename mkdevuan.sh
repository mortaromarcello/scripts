#!/usr/bin/env bash

########################################################################
LOG="$(pwd)/mkdevuan.log"
PATH_SCRIPTS=$(dirname $0)
FRONTEND=noninteractive
VERBOSE=
STAGE=1
CLEAN=0
CLEAN_SNAPSHOT=0
KEYBOARD=it
LOCALE="it_IT.UTF-8 UTF-8"
LANG="it_IT.UTF-8"
TIMEZONE="Europe/Rome"
LANGUAGE="italian"
ARCHIVE=$(pwd)
DE=xfce
ARCH=amd64
DIST=jessie
ROOT_DIR=devuan
INCLUDES="linux-image-$ARCH grub-pc locales console-setup ssh firmware-linux wireless-tools"
APT_OPTS="--assume-yes"
INSTALL_DISTRO_DEPS="git sudo parted rsync squashfs-tools xorriso live-boot live-boot-initramfs-tools live-config-sysvinit live-config syslinux isolinux"
ISO_DEBUG=1
if [ $ISO_DEBUG == 1 ]; then
	PACKAGES="$PACKAGES shellcheck bashdb"
fi

USERNAME=devuan
PASSWORD=devuan
SHELL=/bin/bash
HOSTNAME=devuan
CRYPT_PASSWD=$(perl -e 'printf("%s\n", crypt($ARGV[0], "password"))' "$PASSWORD")
MIRROR=http://auto.mirror.devuan.org/merged
########################################################################
# crea usb live
########################################################################
SYSLINUX_DIR="/usr/lib/syslinux/modules/bios"
SYSLINUX_INST="/boot/syslinux"
MBR_DIR="/usr/lib/syslinux/mbr"
SIZE_PRIMARY_PART=4096M
SIZE_SECONDARY_PART=
TYPE_SECONDARY_PART=L
TYPE_SECONDARY_FS=ext4
DEVICE_USB=
PATH_TO_MOUNT="/mnt"

function create_grub-uefi() {
	git clone http://github.com/mortaromarcello/scripts.git $GIT_DIR/scripts
	cp -av $GIT_DIR/scripts/grub-uefi/* ${PATH_TO_MOUNT}/
}

function create_partitions() {
	echo "Sovrascrivo la tabella delle partizioni."
	parted -s ${DEVICE_USB} mktable msdos
	read -p "Creo la partizione primaria fat32 e la partizione secondaria ext4 (premere Invio o Crtl-c per uscire)"
	sfdisk ${DEVICE_USB} << EOF
,${SIZE_PRIMARY_PART},c,*
,${SIZE_SECONDARY_PART},${TYPE_SECONDARY_PART}
EOF
	sync && sync
	#echo -e ",4096,c,*\n,,83" | sfdisk -D -u M ${1}
	read -p "Formatto la prima partizione. (premere Invio o Crtl-c per uscire)"
	#echo -e "mkpart primary fat32 1 -1\nset 1 boot on\nq\n" | parted ${1}
	mkdosfs -F 32 ${DEVICE_USB}1
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

function install_syslinux() {
	if [ -e /usr/bin/syslinux ]; then
		mount ${DEVICE_USB}1 ${PATH_TO_MOUNT}
		if ! mount | grep ${PATH_TO_MOUNT}; then
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
		if [ $GRUB_UEFI = 1 ]; then
			create_grub-uefi
		fi
		sync && sync
		umount -v $PATH_TO_MOUNT
		echo "Fatto!"
	else
		echo "syslinux non è installato sul tuo sistema. Esco."
	fi
}

########################################################################
#
########################################################################
function linux_firmware() {
	FIRMWARE_DIR=$ARCHIVE/linux-firmware
	[[ -d $FIRMWARE_DIR ]] && rm -R $FIRMWARE_DIR
	git clone git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git $FIRMWARE_DIR
	cp -var $FIRMWARE_DIR/* $1/lib/firmware/
}

function create_pendrive_live() {
	if mount | grep ${PATH_TO_MOUNT}; then
		umount -v ${PATH_TO_MOUNT}
	fi
	if mount | grep ${DEVICE_USB}1; then
		umount -v ${DEVICE_USB}1
	fi
	if mount | grep ${DEVICE_USB}2; then
		umount -v ${DEVICE_USB}2
	fi
	echo -e "Posso cancellare la pennetta e ricreare la partizione. Sei d'accordo (s/n)?"
	read sn
	if [ ${sn} = "s" ]; then
		create_partitions
	fi
	install_syslinux
}

########################################################################
# compile_debootstrap
########################################################################
function compile_debootstrap() {
	DEBOOTSTRAP_DIR=$ARCHIVE/debootstrap
	export DEBOOTSTRAP_DIR
	[[ -d $DEBOOTSTRAP_DIR ]] && rm -R $DEBOOTSTRAP_DIR
	git clone https://git.devuan.org/hellekin/debootstrap.git $DEBOOTSTRAP_DIR
	cd $DEBOOTSTRAP_DIR
	make devices.tar.gz
	DEBOOTSTRAP_BIN=$DEBOOTSTRAP_DIR/debootstrap
	cd $ARCHIVE
}

########################################################################
# ctrl_c
########################################################################
trap ctrl_c SIGINT
ctrl_c() {
	echo "*** CTRL-C pressed***"
	unbind $ROOT_DIR
	exit -1
}

########################################################################
# bind()
########################################################################
function bind() {
	dirs="dev dev/pts proc sys run"
	for dir in $dirs; do
		if ! mount | grep $1/$dir; then
			mount $VERBOSE --bind /$dir $1/$dir
		fi
	done
}

########################################################################
#
########################################################################
function unbind() {
	dirs="run sys proc dev/pts dev"
	for dir in $dirs; do
		if mount | grep $1/$dir; then
			umount -l $VERBOSE $1/$dir
		fi
	done
}

########################################################################
#
########################################################################
function log() {
	echo -e "$(date):\n\tstage $1\n\tdistribution $DIST\n\troot directory $ROOT_DIR\n\tkeyboard $KEYBOARD\n\tlocale $LOCALE\n\tlanguage $LANG\n\ttimezone $TIMEZONE\n\tdesktop $DE\n\tarchitecture $ARCH">>$LOG
}

########################################################################
#
########################################################################
function update() {
	echo -e $APT_REPS > $1/etc/apt/sources.list
	chroot $1 apt update
}

########################################################################
#
########################################################################
function upgrade() {
	chroot $1 /bin/bash -c "DEBIAN_FRONTEND=$FRONTEND apt-get $APT_OPTS dist-upgrade"
}

########################################################################
#
########################################################################
function add_user() {
	chroot $1 useradd -m -p $CRYPT_PASSWD -s $SHELL $USERNAME
}

########################################################################
#
########################################################################
function set_locale() {
	echo $TIMEZONE > $1/etc/timezone
	LINE=$(cat $1/etc/locale.gen|grep "${LOCALE}")
	sed -i "s/${LINE}/${LOCALE}/" $1/etc/locale.gen
	chroot $1 locale-gen
	chroot $1 update-locale LANG=${LANG}
	LINE=$(cat $1/etc/default/keyboard|grep "XKBLAYOUT")
	sed -i "s/${LINE}/XKBLAYOUT=\"${KEYBOARD}\"/" $1/etc/default/keyboard
}

########################################################################
# snapshot() : necessita di montare le dirs dev sys run etc.
########################################################################
function create_snapshot() {
	cp -v $PATH_SCRIPTS/snapshot.sh $1/tmp/
	chmod -v +x $1/tmp/snapshot.sh
	chroot $1 /bin/bash -c "/tmp/snapshot.sh -d Devuan -k $KEYBOARD -l $LOCALE -u $USERNAME"
}

########################################################################
#
########################################################################
function set_distro_env() {
	if [ $DIST = "jessie" ]; then
		APT_REPS="deb http://auto.mirror.devuan.org/merged jessie main contrib non-free\n"
	elif [ $DIST = "ascii" ]; then
		APT_REPS="deb http://auto.mirror.devuan.org/merged jessie main contrib non-free\ndeb http://auto.mirror.devuan.org/merged ascii main contrib non-free\n"
		#INSTALL_DISTRO_DEPS="$INSTALL_DISTRO_DEPS yad"
	elif [ $DIST = "ceres" ]; then
		APT_REPS="deb http://auto.mirror.devuan.org/merged jessie main contrib non-free\ndeb http://auto.mirror.devuan.org/merged ascii main contrib non-free\ndeb http://auto.mirror.devuan.org/merged ceres main contrib non-free\n"
	fi
	compile_debootstrap
}

function jessie() {
	DIST="jessie"
	check_script
	fase1 $ROOT_DIR
	fase2 $ROOT_DIR
	fase3 $ROOT_DIR
	fase4 $ROOT_DIR
}

function ascii() {
	DIST="ascii"
	check_script
	fase1 $ROOT_DIR
	fase2 $ROOT_DIR
	fase3 $ROOT_DIR
	fase4 $ROOT_DIR
}

function ceres() {
	DIST="ceres"
	check_script
	fase1 $ROOT_DIR
	fase2 $ROOT_DIR
	fase3 $ROOT_DIR
	fase4 $ROOT_DIR
}

########################################################################
#
########################################################################
function fase1() {
	log
	[ $CLEAN = 1 ] && rm $VERBOSE -R $ROOT_DIR
	mkdir -p $1
	$DEBOOTSTRAP_BIN --verbose --arch=$ARCH $DIST $1 $MIRROR
	if [ $? -gt 0 ]; then
		echo "Big problem!!!"
		echo -e "===============ERRORE==============">>$LOG
		log
		echo -e "===================================">>$LOG
		exit
	fi
}

########################################################################
#
########################################################################
function fase2() {
	bind $1
	update $1
	upgrade $1
	hook_hostname $1
	chroot $1 /bin/bash -c "DEBIAN_FRONTEND=$FRONTEND apt-get $APT_OPTS autoremove --purge"
	chroot $1 /bin/bash -c "DEBIAN_FRONTEND=$FRONTEND apt-get $APT_OPTS install $INCLUDES"
	if [ $? -gt 0 ]; then
		echo "Big problem!!!"
		echo -e "===============ERRORE==============">>$LOG
		log
		echo -e "===================================">>$LOG
		unbind $1
		exit
	fi
	linux_firmware $1
	add_user $1
	set_locale $1
	chroot $1 /bin/bash -c "DEBIAN_FRONTEND=$FRONTEND apt-get $APT_OPTS install $INSTALL_DISTRO_DEPS"
	if [ $? -gt 0 ]; then
		echo "Big problem!!!"
		echo -e "===============ERRORE==============">>$LOG
		log
		echo -e "===================================">>$LOG
		unbind $1
		exit
	fi
	hook_install_distro $1
	unbind $1
}

########################################################################
#
########################################################################
function fase3() {
	bind $1
	chroot $1 dpkg --configure -a --force-confdef,confnew
	chroot $1 /bin/bash -c "DEBIAN_FRONTEND=$FRONTEND apt-get $APT_OPTS install $PACKAGES"
	if [ $? -gt 0 ]; then
		echo "Big problem!!!"
		echo -e "===============ERRORE==============">>$LOG
		log
		echo -e "===================================">>$LOG
		unbind $1
		exit
	fi
	hook_synaptics $1
	unbind $1
}

########################################################################
#
########################################################################
function fase4() {
	update $1
	bind $1
	upgrade $1
	if [ $? -gt 0 ]; then
		echo "Big problem!!!"
		echo -e "===============ERRORE==============">>$LOG
		log
		echo -e "===================================">>$LOG
		unbind $1
		exit
	fi
	chroot $1 apt-get $APT_OPTS clean
	chroot $1 apt-get $APT_OPTS autoremove --purge
	chroot $1 dpkg --purge -a
	[ $CLEAN_SNAPSHOT = 1 ] && rm $VERBOSE $ROOT_DIR/home/snapshot/snapshot-* $VERBOSE $ROOT_DIR/home/snapshot/filesystem.squashfs-*
	create_snapshot $1
	unbind $1
}

########################################################################
#                         HOOKS                                        #
########################################################################
#
########################################################################
function update_hooks() {
	hook_install_distro $1
	hook_hostname $1
	hook_synaptics $1
	
}
########################################################################
#                   hook_install_distro                                #
########################################################################
function hook_install_distro() {
	TMP="/tmp/scripts"
	GIT_DIR="scripts"
	chroot $1 mkdir -p $TMP
	chroot $1 git clone https://github.com/mortaromarcello/scripts.git $TMP/$GIT_DIR
	chroot $1 cp $VERBOSE -a $TMP/$GIT_DIR/simple_install_distro.sh /usr/local/bin/install_distro.sh
	chroot $1 chmod $VERBOSE +x /usr/local/bin/install_distro.sh
	#if [ $DIST = "ascii" ]; then
	#	chroot $1 cp $VERBOSE -a $TMP/$GIT_DIR/yad_install_distro.sh /usr/local/bin/
	#	chroot $1 chmod $VERBOSE +x /usr/local/bin/yad_install_distro.sh
	#fi
	chroot $1 rm -R -f $VERBOSE ${TMP}
}

########################################################################
#                        hook_synaptics
########################################################################
function hook_synaptics() {
	SYNAPTICS_CONF="# Example xorg.conf.d snippet that assigns the touchpad driver\n\
# to all touchpads. See xorg.conf.d(5) for more information on\n\
# InputClass.\n\
# DO NOT EDIT THIS FILE, your distribution will likely overwrite\n\
# it when updating. Copy (and rename) this file into\n\
# /etc/X11/xorg.conf.d first.\n\
# Additional options may be added in the form of\n\
#   Option \"OptionName\" \"value\"\n\
#\n\
\n\
Section \"InputClass\"\n\
        Identifier      \"Touchpad\"                      # required\n\
        MatchIsTouchpad \"yes\"                           # required\n\
        Driver          \"synaptics\"                     # required\n\
        Option          \"MinSpeed\"              \"0.5\"\n\
        Option          \"MaxSpeed\"              \"1.0\"\n\
        Option          \"AccelFactor\"           \"0.075\"\n\
        Option          \"TapButton1\"            \"1\"\n\
        Option          \"TapButton2\"            \"2\"     # multitouch\n\
        Option          \"TapButton3\"            \"3\"     # multitouch\n\
        Option          \"VertTwoFingerScroll\"   \"1\"     # multitouch\n\
        Option          \"HorizTwoFingerScroll\"  \"1\"     # multitouch\n\
        Option          \"VertEdgeScroll\"        \"1\"\n\
        Option          \"CoastingSpeed\"         \"8\"\n\
        Option          \"CornerCoasting\"        \"1\"\n\
        Option          \"CircularScrolling\"     \"1\"\n\
        Option          \"CircScrollTrigger\"     \"7\"\n\
        Option          \"EdgeMotionUseAlways\"   \"1\"\n\
        Option          \"LBCornerButton\"        \"8\"     # browser \"back\" btn\n\
        Option          \"RBCornerButton\"        \"9\"     # browser \"forward\" btn\n\
EndSection\n\
#\n\
Section \"InputClass\"\n\
        Identifier \"touchpad catchall\"\n\
        Driver \"synaptics\"\n\
        MatchIsTouchpad \"on\"\n\
# This option is recommend on all Linux systems using evdev, but cannot be\n\
# enabled by default. See the following link for details:\n\
# http://who-t.blogspot.com/2010/11/how-to-ignore-configuration-errors.html\n\
#       MatchDevicePath \"/dev/input/event*\"\n\
EndSection\n\
\n\
Section \"InputClass\"\n\
        Identifier \"touchpad ignore duplicates\"\n\
        MatchIsTouchpad \"on\"\n\
        MatchOS \"Linux\"\n\
        MatchDevicePath \"/dev/input/mouse*\"\n\
        Option \"Ignore\" \"on\"\n\
EndSection\n\
\n\
# This option enables the bottom right corner to be a right button on clickpads\n\
# and the right and middle top areas to be right / middle buttons on clickpads\n\
# with a top button area.\n\
# This option is only interpreted by clickpads.\n\
Section \"InputClass\"\n\
        Identifier \"Default clickpad buttons\"\n\
        MatchDriver \"synaptics\"\n\
        Option \"SoftButtonAreas\" \"50% 0 82% 0 0 0 0 0\"\n\
        Option \"SecondarySoftButtonAreas\" \"58% 0 0 15% 42% 58% 0 15%\"\n\
EndSection\n\
\n\
# This option disables software buttons on Apple touchpads.\n\
# This option is only interpreted by clickpads.\n\
Section \"InputClass\"\n\
        Identifier \"Disable clickpad buttons on Apple touchpads\"\n\
        MatchProduct \"Apple|bcm5974\"\n\
        MatchDriver \"synaptics\"\n\
        Option \"SoftButtonAreas\" \"0 0 0 0 0 0 0 0\"\n\
EndSection\n\
"
	mkdir -p $1/etc/X11/xorg.conf.d
	echo -e "$SYNAPTICS_CONF" >$1/etc/X11/xorg.conf.d/50-synaptics.conf
}

########################################################################
#                   hook_hostname
########################################################################
function hook_hostname() {
	cat > $1/etc/hostname <<EOF
${HOSTNAME}
EOF
	cat > $1/etc/hosts <<EOF
127.0.0.1       localhost
127.0.1.1       ${HOSTNAME}
::1             localhost ip6-localhost ip6-loopback
fe00::0         ip6-localnet
ff00::0         ip6-mcastprefix
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
EOF
}

########################################################################

########################################################################
#
########################################################################
function check_script() {
	if [ $DIST != jessie ] && [ $DIST != ascii ] && [ $DIST != ceres ]; then
		DIST=jessie
	fi
	if [ $ARCH != i386 ] && [ $ARCH != amd64 ]; then
		ARCH=amd64
	fi
	if [ $DE != "mate" ] && [ $DE != "xfce" ] && [ $DE != "lxde" ] && [ $DE != "kde" ]; then
		DE="xfce"
	fi
	if [ $(id -u) != 0 ]; then
		echo -e "\nUser $USER not is root."
		exit
	fi
	PACKAGES="filezilla vinagre telnet ntp testdisk recoverdm myrescue gpart gsmartcontrol diskscan exfat-fuse task-laptop task-$DE-desktop task-$LANGUAGE iceweasel-l10n-$KEYBOARD cups wicd geany geany-plugins smplayer putty pulseaudio-module-bluetooth blueman"
	set_distro_env
########################################################################
	if [ ${TYPE_SECONDARY_FS} = "exfat" ]; then
		TYPE_SECONDARY_PART=7
	elif [ ${TYPE_SECONDARY_FS} = "vfat" ]; then
		TYPE_SECONDARY_PART=c
	fi
	
	if [ -n $DEVICE_USB ]; then
		echo "device usb $DEVICE_USB"
		echo "path to mount $PATH_TO_MOUNT"
		echo "syslinux install path $SYSLINUX_INST"
		echo "size primary partition $SIZE_PRIMARY_PART"
		echo "size secondary filesystem $SIZE_SECONDARY_PART"
		echo "tipo di  filesystem partizione secondaria $TYPE_SECONDARY_FS"
		echo "tipo partizione secondaria $TYPE_SECONDARY_PART"
	fi
########################################################################
	echo "distribution $DIST"
	echo "architecture $ARCH"
	echo "desktop $DE"
	echo "stage $STAGE"
	echo "root directory $ROOT_DIR"
	echo "locale $LOCALE"
	echo "lang $LANG"
	echo "language $LANGUAGE"
	echo "keyboard $KEYBOARD"
	echo "timezone $TIMEZONE"
	echo -e "deb repository $APT_REPS"
	echo "Script verificato. OK."
}

########################################################################
#
########################################################################
function help() {
  echo -e "
${0} <opzioni>
Crea una live Devuan
  -a | --arch <architecture>             :tipo di architettura.
  -d | --distribuition <dist>            :tipo di distribuzione.
  -D | --desktop <desktop>               :tipo di desktop mate(default), xfce o lxde.
  -h | --help                            :Stampa questa messaggio.
  -k | --keyboard                        :Tipo di tastiera (default 'it').
  -l | --locale                          :Tipo di locale (default 'it_IT.UTF-8 UTF-8').
  -L | --lang                            :Lingua (default 'it_IT.UTF-8').
  -n | --hostname                        :Nome hostname (default 'devuan').
  -s | --stage <stage>                   :Numero fase:
                                         1) crea la base del sistema
                                         2) setta lo user, hostname e la lingua e i pacchetti indispensabili
                                         3) installa pacchetti aggiuntivi e il
                                            desktop
                                         4) installa lo script d'installazione
                                            e crea la iso.
                                         min) fase 1 + fase 2 + fase 4
                                         de) fase 1 + fase 2 + fase 3 + fase 4
  -r | --root-dir <dir>                  :Directory della root
  -T | --timezone <timezone>             :Timezone (default 'Europe/Rome').
  -u | --user                            :Nome utente.
"
}

########################################################################
#
########################################################################
[[ -z $1 ]] && help && exit
until [ -z "${1}" ]
do
	case ${1} in
		-a | --arch)
			shift
			ARCH=${1}
			;;
		-c | --clean)
			shift
			CLEAN=1
			;;
		-cs | --clean-snapshoot)
			shift
			CLEAN_SNAPSHOT=1
			;;
		-d | --distribution)
			shift
			DIST=${1}
			;;
		-D | --desktop)
			shift
			DE=${1}
			;;
		-h | --help)
			shift
			help
			exit
			;;
		-k | --keyboard)
			shift
			KEYBOARD=${1}
			;;
		-l | --locale)
			shift
			LOCALE=${1}
			;;
		-L | --lang)
			shift
			LANG=${1}
			;;
		-la | --language)
			shift
			LANGUAGE=${1}
			;;
		-n | --hostname)
			shift
			HOSTNAME=${1}
			;;
		-r | --root-dir)
			shift
			ROOT_DIR=$1
			;;
		-s | --stage)
			shift
			STAGE=${1}
			;;
		-T | --timezone)
			shift
			TIMEZONE=${1}
			;;
		-u | --user)
			shift
			USERNAME=${1}
			;;
		-v | --verbose)
			shift
			VERBOSE=-v
			;;
		*)
			shift
			;;
	esac
done

case $STAGE in
	"")
		;&
	1)
		check_script
		fase1 $ROOT_DIR
		;;
	2)
		check_script
		fase2 $ROOT_DIR
		;;
	3)
		check_script
		fase3 $ROOT_DIR
		;;
	4)
		check_script
		fase4 $ROOT_DIR
		;;
	min)
		check_script
		fase1 $ROOT_DIR
		fase2 $ROOT_DIR
		fase4 $ROOT_DIR
		;;
	jessie)
		jessie
		;;
	ascii)
		ascii
		;;
	ceres)
		ceres
		;;
	iso-update)
		check_script
		update_hooks $ROOT_DIR
		fase4 $ROOT_DIR
		;;
	upgrade)
		check_script
		bind $ROOT_DIR
		update $ROOT_DIR
		upgrade $ROOT_DIR
		unbind $ROOT_DIR
		;;
	-du | --device-usb)
		shift
		DEVICE_USB=${1}
		;;
	-gu | --grub-uefi)
		shift
		GRUB_UEFI=1
			;;
	-pm | --path-to-mount)
		shift
		PATH_TO_MOUNT=${1}
		;;
	-pi | --path-to-install-syslinux)
		shift
		SYSLINUX_INST=${1}
		;;
	-sp | --size-primary-part)
			shift
		SIZE_PRIMARY_PART=${1}M
		;;
	-ss | --size-secondary-part)
		shift
		SIZE_SECONDARY_PART=${1}M
		;;
	-ts | --type-secondary-filesystem)
		shift
		TYPE_SECONDARY_FS=${1}
		;;
	*)
		;;
esac
