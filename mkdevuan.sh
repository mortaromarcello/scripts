#!/usr/bin/env bash

########################################################################
FRONTEND=noninteractive
VERBOSE=
ROOT_DIR=devuan
STAGE=1
CLEAN=0
KEYBOARD=it
LOCALE="it_IT.UTF-8 UTF-8"
LANG="it_IT.UTF-8"
TIMEZONE="Europe/Rome"
ARCHIVE=$(pwd)
DE=mate
ARCH=amd64
DIST=jessie
#INCLUDES="devuan-keyring linux-image-$ARCH grub-pc locales console-setup ssh"
INCLUDES="linux-image-$ARCH grub-pc locales console-setup ssh firmware-linux"
#APT_OPTS="--assume-yes --force-yes"
APT_OPTS="--assume-yes"
REFRACTA_DEPS="rsync squashfs-tools xorriso live-boot live-boot-initramfs-tools live-config-sysvinit live-config syslinux isolinux"
INSTALL_DISTRO_DEPS="git sudo parted"
PACKAGES="task-$DE-desktop wicd geany geany-plugins smplayer putty"
USERNAME=user
PASSWORD=user
SHELL=/bin/bash
CRYPT_PASSWD=$(perl -e 'printf("%s\n", crypt($ARGV[0], "password"))' "$PASSWORD")
MIRROR=http://auto.mirror.devuan.org/merged

########################################################################
function bind() {
	for dir in dev dev/pts proc sys run; do
		mount $VERBOSE --bind /$dir $1/$dir
	done
}

function unbind() {
	for dir in run sys proc dev/pts dev; do
		umount $VERBOSE $1/$dir
	done
}

function update() {
	echo -e $APT_REPS > $1/etc/apt/sources.list
	echo -e $APT_CONF_OPTS >> $1/etc/apt/apt.conf.d/70debconf
	chroot $1 apt update
}

function upgrade() {
	chroot $1 apt $APT_OPTS upgrade
}

function add_user() {
	chroot $1 useradd -m -p $CRYPT_PASSWD -s $SHELL $USERNAME
}

function set_locale() {
	echo $TIMEZONE > $1/etc/timezone
	LINE=$(cat $1/etc/locale.gen|grep "${LOCALE}")
	sed -i "s/${LINE}/${LOCALE}/" $1/etc/locale.gen
	chroot $1 locale-gen
	chroot $1 update-locale LANG=${LANG}
	LINE=$(cat $1/etc/default/keyboard|grep "XKBLAYOUT")
	sed -i "s/${LINE}/XKBLAYOUT=\"${KEYBOARD}\"/" $1/etc/default/keyboard
}

function create_snapshot() {
	chroot $1 refractasnapshot << ANSWERS

Devuan

ANSWERS
}

function set_distro_env() {
	if [ $DIST = "jessie" ]; then
		APT_REPS="deb http://auto.mirror.devuan.org/merged jessie main contrib non-free\n"
		APT_CONF_OPTS="APT::Default-Release \"jessie\";"
	elif [ $DIST = "ascii" ]; then
		APT_REPS="deb http://auto.mirror.devuan.org/merged jessie main contrib non-free\ndeb http://auto.mirror.devuan.org/merged ascii main contrib non-free\n"
		APT_CONF_OPTS="APT::Default-Release \"testing\";"
	elif [ $DIST = "ceres" ]; then
		APT_REPS="deb http://auto.mirror.devuan.org/merged jessie main contrib non-free\ndeb http://auto.mirror.devuan.org/merged ascii main contrib non-free\ndeb http://auto.mirror.devuan.org/merged ceres main contrib non-free\n"
		APT_CONF_OPTS="APT::Default-Release \"testing\";"
	fi
}

function fase1() {
	[ $CLEAN = 1 ] && rm $VERBOSE -R $ROOT_DIR
	mkdir -p $1
	debootstrap --verbose --arch=$ARCH $DIST $1 $MIRROR
	if [ $? -gt 0 ]; then
		echo "Big problem!!!"
		exit
	fi
}

function fase2() {
	bind $1
	update $1
	upgrade $1
	chroot $1 /bin/bash -c "DEBIAN_FRONTEND=$FRONTEND apt-get $APT_OPTS install $INCLUDES"
	if [ $? -gt 0 ]; then
		echo "Big problem!!!"
		unbind $1
		exit
	fi
	if [ ! -f $ARCHIVE/refractasnapshot-base_9.3.3_all.deb ]; then
		wget -P $ARCHIVE http://downloads.sourceforge.net/project/refracta/testing/refractasnapshot-base_9.3.3_all.deb
	fi
	cp $VERBOSE -a $ARCHIVE/refractasnapshot-base_9.3.3_all.deb $1/root/
	add_user $1
	set_locale $1
	chroot $1 /bin/bash -c "DEBIAN_FRONTEND=$FRONTEND apt-get $APT_OPTS install $REFRACTA_DEPS $INSTALL_DISTRO_DEPS"
	if [ $? -gt 0 ]; then
		echo "Big problem!!!"
		unbind $1
		exit
	fi
	chroot $1 dpkg -i /root/refractasnapshot-base_9.3.3_all.deb
	unbind $1
}

function fase3() {
	bind $1
	chroot $1 /bin/bash -c "DEBIAN_FRONTEND=$FRONTEND apt-get $APT_OPTS install $PACKAGES"
	if [ $? -gt 0 ]; then
		echo "Big problem!!!"
		unbind $1
		exit
	fi
	unbind $1
}

function fase4() {
	bind $1
	hook_install_distro $1
	create_snapshot $1
	unbind $1
}

########################################################################
#                         HOOKS                                        #
########################################################################
#                   hook_install_distro                                     #
function hook_install_distro() {
	TMP="/tmp/scripts"
	GIT_DIR="scripts"
	chroot $1 mkdir -p $TMP
	chroot $1 git clone https://github.com/mortaromarcello/scripts.git $TMP/$GIT_DIR
	chroot $1 cp $VERBOSE -a $TMP/$GIT_DIR/simple_install_distro.sh /usr/local/bin/install_distro.sh
	chroot $1 chmod $VERBOSE +x /usr/local/bin/install_distro.sh
	chroot $1 rm -R -f $VERBOSE ${TMP}
}
########################################################################

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
		#help
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
	echo "keyboard $KEYBOARD"
	echo "timezone $TIMEZONE"
	echo -e "deb repository $APT_REPS"
	echo "Script verificato. OK."
}

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
  -L | --language                        :Lingua (default 'it_IT.UTF-8').
  -n | --hostname                        :Nome hostname (default 'devuan').
  -s | --stage <stage>                  :Numero fase:
                                         1) crea la base del sistema
                                         2) installa refractasnapshot,
                                            setta lo user e la lingua
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
		-L | --language)
			shift
			LANG=${1}
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

check_script

case $STAGE in
	"")
		;&
	1)
		fase1 $ROOT_DIR
		;;
	2)
		fase2 $ROOT_DIR
		;;
	3)
		fase3 $ROOT_DIR
		;;
	4)
		fase4 $ROOT_DIR
		;;
	min)
		fase1 $ROOT_DIR
		fase2 $ROOT_DIR
		fase4 $ROOT_DIR
		;;
	de)
		fase1 $ROOT_DIR
		fase2 $ROOT_DIR
		fase3 $ROOT_DIR
		fase4 $ROOT_DIR
		;;
	*)
	;;
esac
