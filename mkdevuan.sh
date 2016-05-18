#!/usr/bin/env bash

########################################################################
LOG="$(pwd)/mkdevuan.log"
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
INCLUDES="linux-image-$ARCH grub-pc locales console-setup ssh firmware-linux"
APT_OPTS="--assume-yes"
REFRACTA_DEPS="rsync squashfs-tools xorriso live-boot live-boot-initramfs-tools live-config-sysvinit live-config syslinux isolinux"
INSTALL_DISTRO_DEPS="git sudo parted"
PACKAGES="task-$DE-desktop wicd geany geany-plugins smplayer putty blueman"
USERNAME=user
PASSWORD=user
SHELL=/bin/bash
CRYPT_PASSWD=$(perl -e 'printf("%s\n", crypt($ARGV[0], "password"))' "$PASSWORD")
MIRROR=http://auto.mirror.devuan.org/merged


########################################################################
SPLASH="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
"

LIVE_CFG="label live\n \
menu label \${DISTRO} (default)\n \
\tkernel /live/vmlinuz\n \
\tappend initrd=/live/initrd.img boot=live \${netconfig_opt} \${username_opt} locales=${LOCALE} keyboard-layouts=${KEYBOARD}\n \
\n \
label nox\n \
\tmenu label \${DISTRO} (text-mode)\n \
\tkernel /live/vmlinuz\n \
\tappend initrd=/live/initrd.img boot=live \${netconfig_opt} 3 \${username_opt} locales=${LOCALE} keyboard-layouts=${KEYBOARD}\n \
\n \
label nomodeset\n \
\tmenu label \${DISTRO} (no modeset)\n \
\tkernel /live/vmlinuz nomodeset\n \
\tappend initrd=/live/initrd.img boot=live \${netconfig_opt} \${username_opt} locales=${LOCALE} keyboard-layouts=${KEYBOARD}\n \
\n \
label toram\n \
\tmenu label \${DISTRO} (load to RAM)\n \
\tkernel /live/vmlinuz\n \
\tappend initrd=/live/initrd.img boot=live \${netconfig_opt} toram \${username_opt} locales=${LOCALE} keyboard-layouts=${KEYBOARD}\n \
\n \
label noprobe\n \
\tmenu label \${DISTRO} (no probe)\n \
\tkernel /live/vmlinuz noapic noapm nodma nomce nolapic nosmp vga=normal\n \
\tappend initrd=/live/initrd.img boot=live \${netconfig_opt} \${username_opt} locales=${LOCALE} keyboard-layouts=${KEYBOARD}\n \
\n \
label memtest\n \
\tmenu label Memory test\n \
\tkernel /live/memtest\n \
\n \
label chain.c32 hd0,0\n \
\tmenu label Boot hard disk\n \
\tchain.c32 hd0,0\n \
\n \
label harddisk\n \
\tmenu label Boot hard disk (old way)\n \
\tlocalboot 0x80\n
"
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

function log() {
	echo -e "$(date):\n\tstage $1\n\tdistribution $DIST\n\troot directory $ROOT_DIR\n\tkeyboard $KEYBOARD\n\tlocale $LOCALE\n\tlanguage $LANG\n\ttimezone $TIMEZONE\n\tdesktop $DE\n\tarchitecture $ARCH">>$LOG
}

function update() {
	echo -e $APT_REPS > $1/etc/apt/sources.list
	chroot $1 apt update
}

function upgrade() {
	if [ $DIST = "ascii" ] || [ $DIST = "ceres" ]; then
		chroot $1 /bin/bash -c "DEBIAN_FRONTEND=$FRONTEND apt-get -t ascii $APT_OPTS dist-upgrade"
	else
		chroot $1 /bin/bash -c "DEBIAN_FRONTEND=$FRONTEND apt-get $APT_OPTS dist-upgrade"
	fi
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
	elif [ $DIST = "ascii" ]; then
		APT_REPS="deb http://auto.mirror.devuan.org/merged jessie main contrib non-free\ndeb http://auto.mirror.devuan.org/merged ascii main contrib non-free\n"
	elif [ $DIST = "ceres" ]; then
		APT_REPS="deb http://auto.mirror.devuan.org/merged jessie main contrib non-free\ndeb http://auto.mirror.devuan.org/merged ascii main contrib non-free\ndeb http://auto.mirror.devuan.org/merged ceres main contrib non-free\n"
	fi
}

function isolinux() {
	echo "$SPLASH" | base64 --decode > $1/usr/lib/refractasnapshot/iso/isolinux/splash.png
	echo -e $LIVE_CFG > $1/usr/lib/refractasnapshot/iso/isolinux/live.cfg
}

function fase1() {
	log
	[ $CLEAN = 1 ] && rm $VERBOSE -R $ROOT_DIR
	mkdir -p $1
	debootstrap --verbose --arch=$ARCH $DIST $1 $MIRROR
	if [ $? -gt 0 ]; then
		echo "Big problem!!!"
		echo -e "===============ERRORE==============">>$LOG
		log
		echo -e "===================================">>$LOG
		exit
	fi
}

function fase2() {
	bind $1
	update $1
	upgrade $1
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
	if [ ! -f $ARCHIVE/refractasnapshot-base_9.3.3_all.deb ]; then
		wget -P $ARCHIVE http://downloads.sourceforge.net/project/refracta/testing/refractasnapshot-base_9.3.3_all.deb
	fi
	cp $VERBOSE -a $ARCHIVE/refractasnapshot-base_9.3.3_all.deb $1/root/
	add_user $1
	set_locale $1
	chroot $1 /bin/bash -c "DEBIAN_FRONTEND=$FRONTEND apt-get $APT_OPTS install $REFRACTA_DEPS $INSTALL_DISTRO_DEPS"
	if [ $? -gt 0 ]; then
		echo "Big problem!!!"
		echo -e "===============ERRORE==============">>$LOG
		log
		echo -e "===================================">>$LOG
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
		echo -e "===============ERRORE==============">>$LOG
		log
		echo -e "===================================">>$LOG
		unbind $1
		exit
	fi
	unbind $1
}

function fase4() {
	bind $1
	chroot $1 apt update
	chroot $1 /bin/bash -c "DEBIAN_FRONTEND=$FRONTEND apt-get $APT_OPTS upgrade"
	if [ $? -gt 0 ]; then
		echo "Big problem!!!"
		echo -e "===============ERRORE==============">>$LOG
		log
		echo -e "===================================">>$LOG
		unbind $1
		exit
	fi
	chroot $1 apt-get clean
	hook_install_distro $1
	isolinux $1
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
	jessie)
		DIST="jessie"
		fase1 $ROOT_DIR
		fase2 $ROOT_DIR
		fase3 $ROOT_DIR
		fase4 $ROOT_DIR
		;;
	ascii)
		DIST="ascii"
		fase1 $ROOT_DIR
		fase2 $ROOT_DIR
		fase3 $ROOT_DIR
		fase4 $ROOT_DIR
		;;
	ceres)
		DIST="ceres"
		fase1 $ROOT_DIR
		fase2 $ROOT_DIR
		fase3 $ROOT_DIR
		fase4 $ROOT_DIR
		;;
	*)
	;;
esac
