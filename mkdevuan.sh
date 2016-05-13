#!/usr/bin/env bash

if [ -z $1 ]; then
	#
	exit
fi

########################################################################
FRONTEND=noninteractive
LOCALE="it_IT.UTF-8 UTF-8"
LANG="it_IT.UTF-8"
TIMEZONE="Europe/Rome"
ARCHIVE=$(pwd)
DE=mate
ARCH=amd64
DIST=stable
INCLUDES=devuan-keyring,linux-image-$ARCH,grub-pc,locales,console-setup,ssh
APT_OPTS="--assume-yes --force-yes"
REFRACTA_DEPS="rsync squashfs-tools xorriso live-boot live-boot-initramfs-tools live-config-sysvinit live-config syslinux isolinux"
INSTALL_DISTRO_DEPS="git gksu parted"
PACKAGES="task-$DE-desktop wicd geany geany-plugins smplayer putty"
USER=user
PASSWORD=user
SHELL=/bin/bash
CRYPT_PASSWD=$(perl -e 'printf("%s\n", crypt($ARGV[0], "password"))' "$PASSWORD")
MIRROR=http://auto.mirror.devuan.org/merged
########################################################################
function bind() {
	for dir in dev dev/pts proc sys; do
		mount -v --bind /$dir $1/$dir
	done
}

function unbind() {
	for dir in sys proc dev/pts dev; do
		umount -v $1/$dir
	done
}

function add_user() {
	chroot $1 useradd -m -p $CRYPT_PASSWD -s $SHELL $USER
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

function fase1() {
	mkdir -p $1
	debootstrap --verbose --arch=$ARCH --include $INCLUDES $DIST $1 $MIRROR
	if [ $? -gt 0 ]; then
		echo "Big problem!!!"
		exit
	fi
}

function fase2() {
	wget -P $ARCHIVE http://downloads.sourceforge.net/project/refracta/testing/refractasnapshot-base_9.3.3_all.deb 
	cp -va $ARCHIVE/refractasnapshot-base_9.3.3_all.deb $1/root/
	bind $1
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
	chroot $1 cp -va $TMP/$GIT_DIR/simple_install_distro.sh /usr/local/bin/install_distro.sh
	chroot $1 chmod -v +x /usr/local/bin/install_distro.sh
	chroot $1 rm -R -f -v ${TMP}
}
########################################################################

########################################################################

case $2 in
	"")
		;&
	fase1)
		fase1 $1
		;;
	fase2)
		fase2 $1
		;;
	fase3)
		fase3 $1
		;;
	fase4)
		fase4 $1
		;;
	min)
		fase1 $1
		fase2 $1
		fase4 $1
		;;
	de)
		fase1 $1
		fase2 $1
		fase3 $1
		fase4 $1
		;;
	*)
	;;
esac
