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
INCLUDES="linux-image-$ARCH grub-pc locales console-setup ssh firmware-linux"
APT_OPTS="--assume-yes"
INSTALL_DISTRO_DEPS="git sudo parted rsync squashfs-tools xorriso live-boot live-boot-initramfs-tools live-config-sysvinit live-config syslinux isolinux"
PACKAGES="vinagre telnet ntp testdisk recoverdm myrescue gpart gsmartcontrol diskscan exfat-fuse task-laptop task-$DE-desktop task-$LANGUAGE iceweasel-l10n-$KEYBOARD wicd geany geany-plugins smplayer putty pulseaudio-module-bluetooth blueman"

USERNAME=devuan
PASSWORD=devuan
SHELL=/bin/bash
HOSTNAME=devuan
CRYPT_PASSWD=$(perl -e 'printf("%s\n", crypt($ARGV[0], "password"))' "$PASSWORD")
MIRROR=http://auto.mirror.devuan.org/merged

########################################################################
# compile_debootstrap
########################################################################
function compile_debootstrap() {
	 [[ -d debootstrap ]] && rm -R debootstrap
	git clone https://git.devuan.org/hellekin/debootstrap.git
	cd debootstrap
	make devices.tar.gz
	DEBOOTSTRAP_DIR=`pwd`
	export DEBOOTSTRAP_DIR
	DEBOOTSTRAP_BIN=$DEBOOTSTRAP_DIR/debootstrap
	cd $ARCHIVE
}

########################################################################
# ctrl_c
########################################################################
trap ctrl_c SIGINT
ctrl_c() {
	echo "*** CTRL-C pressed***"
	if [ -b $ROOT_DIR/dev ]; then
		unbind $ROOT_DIR
	fi
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
		INSTALL_DISTRO_DEPS="$INSTALL_DISTRO_DEPS yad"
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
	bind $1
	create_snapshot $1
	unbind $1
}

########################################################################
#                         HOOKS                                        #
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
	if [ $DIST = "ascii" ]; then
		chroot $1 cp $VERBOSE -a $TMP/$GIT_DIR/yad_install_distro.sh /usr/local/bin/
		chroot $1 chmod $VERBOSE +x /usr/local/bin/yad_install_distro.sh
	fi
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
	if [ $DE != "mate" ] && [ $DE != "xfce" ] && [ $DE != "lxde" ]; then
		DE="mate"
	fi
	if [ $(id -u) != 0 ]; then
		echo -e "\nUser $USER not is root."
		exit
	fi
	set_distro_env
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
		[ $CLEAN_SNAPSHOT = 1 ] && rm $VERBOSE $ROOT_DIR/home/snapshot/snapshot-*
		fase4 $ROOT_DIR
		;;
	upgrade)
		check_script
		bind $ROOT_DIR
		update $ROOT_DIR
		upgrade $ROOT_DIR
		unbind $ROOT_DIR
		;;
	*)
		;;
esac
