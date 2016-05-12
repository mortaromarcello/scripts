#!/usr/bin/env bash
if [ -z $1 ]; then
	exit
fi
FRONTEND=noninteractive
LANG="it_IT.UTF-8"
TIMEZONE="Europe/Rome"
ARCHIVE=/home/marcello/Scaricati/deb
DE=mate
ARCH=amd64
DIST=stable
INCLUDES=devuan-keyring,linux-image-$ARCH,grub-pc,locales,console-setup,ssh
#APT_OPTS="--no-install-recommends --assume-yes"
APT_OPTS="--assume-yes"
REFRACTA_DEPS="rsync squashfs-tools xorriso live-boot live-boot-initramfs-tools live-config-sysvinit live-config syslinux isolinux"
INSTALL_DISTRO_DEPS="python-wxgtk3.0 python-parted git gksu parted"
PACKAGES="task-$DE-desktop wicd geany geany-plugins"
USER=user
PASSWORD=user
SHELL=/bin/bash
CRYPT_PASSWD=$(perl -e 'printf("%s\n", crypt($ARGV[0], "password"))' "$PASSWORD")
#MIRROR="http://packages.devuan.org/merged"
MIRROR=http://auto.mirror.devuan.org/merged
mkdir -p $1
debootstrap --verbose --arch=$ARCH --include $INCLUDES $DIST $1 $MIRROR
if [ $? -gt 0 ]; then
	echo "Big problem!!!"
	exit
fi
cp -va $ARCHIVE/refracta*_all.deb $1/root/

########################################################################
for dir in dev dev/pts proc sys; do
	mount -v --bind /$dir $1/$dir
done
########################################################################
chroot $1 useradd -m -p $CRYPT_PASSWD -s $SHELL $USER
chroot $1 echo $TIMEZONE > /etc/timezone
chroot $1 dpkg-reconfigure --frontend=$FRONTEND tzdata
chroot $1 sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
chroot $1 sed -i -e 's/# $LANG UTF-8/$LANG UTF-8/' /etc/locale.gen
chroot $1 echo 'LANG=$LANG'>/etc/default/locale
chroot $1 dpkg-reconfigure --frontend=$FRONTEND locales
chroot $1 update-locale LANG=it_IT.UTF-8
chroot $1 DEBIAN_FRONTEND=$FRONTEND apt-get -y install $REFRACTA_DEPS $INSTALL_DISTRO_DEPS
chroot $1 dpkg -i /root/refractasnapshot-base_9.3.3_all.deb
chroot $1 dpkg -i /root/refractainstaller-base_9.1.8_all.deb
#chroot $1 apt-get -fy install
chroot $1 DEBIAN_FRONTEND=$FRONTEND apt-get $APT_OPTS install $PACKAGES

########################################################################
#                         HOOKS                                        #
########################################################################
#                   install_distro                                     #
TMP="/tmp/scripts"
GIT_DIR="scripts"
chroot $1 mkdir -p $TMP
chroot $1 git clone https://github.com/mortaromarcello/scripts.git $TMP/$GIT_DIR
chroot $1 cp -va $TMP/$GIT_DIR/simple_install_distro.sh /usr/local/bin/install_distro.sh
chroot $1 chmod -v +x /usr/local/bin/install_distro.sh
INSTALL_DISTRO="/usr/local/share/install_distro"
chroot $1 mkdir -p ${INSTALL_DISTRO}
chroot $1 cp -va $TMP/$GIT_DIR/install_distro{.py,.png} ${INSTALL_DISTRO}
chroot $1 chmod -v +x ${INSTALL_DISTRO}/install_distro.py
chroot $1 cp -R -va $TMP/$GIT_DIR/locale /usr/local/share/
chroot $1 cp -va $TMP/$GIT_DIR/install_distro /usr/local/bin
chroot $1 chmod -v +x /usr/local/bin/install_distro
cat >$1/tmp/install_distro.desktop<<EOF
[Desktop Entry]
Type=Application
Name=Installa Livedevelop
Comment=
Icon=/usr/local/share/install_distro/install_distro.png
Exec=x-terminal-emulator -e gksu /usr/local/bin/install_distro
Terminal=false
Categories=System;
EOF
chroot $1 cp -va /tmp/install_distro.desktop /usr/share/applications/
chroot $1 rm -f -v /tmp/install_distro.desktop
chroot $1 rm -R -f -v ${TMP}
########################################################################
chroot $1 refractasnapshot << ANSWERS

Devuan

ANSWERS

########################################################################
for dir in sys proc dev/pts dev; do
	umount -v $1/$dir
done
