#!/bin/bash

DEBUG="yes"

########################################################################
# environment: variabili script
########################################################################

TEMP_REPOSITORY="repo"
LOG="$(pwd)/mkdevuan.log"
PATH_SCRIPTS=$(dirname $0)
FRONTEND=noninteractive
VERBOSE=
STAGE=1
CLEAN=0
COMPILE_BOOTSTRAP=1
DEBOOTSTRAP_BIN=/usr/sbin/debootstrap
SNAPSHOT=
CLEAN_SNAPSHOT=0
KEYBOARD=it
LOCALE="it_IT.UTF-8 UTF-8"
LANG="it_IT.UTF-8"
TIMEZONE="Europe/Rome"
LANGUAGE="italian"
ARCHIVE=$(pwd)
DE=kde
ARCH=amd64
DIST=ascii
ROOT_DIR=devuan
PACKAGES_FILE="packages_kde"
INCLUDES="linux-image-$ARCH grub-pc refind locales console-setup ssh firmware-linux wireless-tools devuan-keyring rpl mc sharutils"
APT_OPTS="--assume-yes"
INSTALL_DISTRO_DEPS="git sudo parted rsync squashfs-tools xorriso live-boot live-boot-initramfs-tools live-config-sysvinit live-config syslinux isolinux"
ISO_DEBUG=1
if [ $ISO_DEBUG == 1 ]; then
    PACKAGES="shellcheck $PACKAGES" 
fi

USERNAME=devuan
PASSWORD=devuan
SHELL=/bin/bash
HOSTNAME=devuan
CRYPT_PASSWD=$(perl -e 'printf("%s\n", crypt($ARGV[0], "password"))' "$PASSWORD")
MIRROR=http://pkgmaster.devuan.org/merged

########################################################################
# crea usb live
########################################################################
SYSLINUX_INST="/isolinux"
MBR_DIR="/usr/lib/syslinux/mbr"
SIZE_PRIMARY_PART=4096M
SIZE_SECONDARY_PART=
TYPE_SECONDARY_PART=L
TYPE_SECONDARY_FS=ext4
DEVICE_USB=
PATH_TO_MOUNT="/tmp/part"

ICON="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
rkJggg==
"

########################################################################
# is_removible:
########################################################################
function is_removable() {
    DEVICE=$(echo "${DEVICE_USB}" | cut -d'/' -f 3)
    if [ $(cat "/sys/block/$DEVICE/removable") == "0" ]; then
        log "Line:${LINENO} - Il device non è removibile." "f"
    else
        log "Il device è removibile. OK!" "i"
    fi
}

########################################################################
# install_refind:
########################################################################
function install_refind() {
    if [ -e /usr/sbin/refind-install ]; then
        if [ "${DEVICE_USB}" ]; then
            log "Installo refind." "i"
            refind-install --usedefault "${DEVICE_USB}1" --alldrivers
            log "Monto la partizione ${DEVICE_USB}1 su ${PATH_TO_MOUNT}" "i"
            mount ${DEVICE_USB}1 ${PATH_TO_MOUNT}
            echo "$ICON" | base64 --decode > "${PATH_TO_MOUNT}"/EFI/BOOT/icons/os_devuan.png
            cat >> "${PATH_TO_MOUNT}"/EFI/BOOT/refind.conf<<EOF
menuentry Devuan {
    icon /EFI/BOOT/icons/os_devuan.png
    loader /live/vmlinuz
    initrd /live/initrd.img
    options "boot=live 3 username=${USERNAME} locales=${LOCALE} keyboard-layouts=${KEYBOARD} persistence"
}
EOF
            log "Smonto la partizione ${DEVICE_USB}1 su ${PATH_TO_MOUNT}" "i"
            umount ${DEVICE_USB}1
        else
            log "Line:${LINENO} - Il device usb non è impostato" "f"
        fi
    else
        log "Line:${LINENO} - refind non è installato." "f"
    fi
}

########################################################################
# create_partitions:
########################################################################
function create_partitions() {
    log "Sovrascrivo la tabella delle partizioni." "i"
    parted -s ${DEVICE_USB} mktable msdos
    log "Creo la partizione primaria fat32 e la partizione secondaria ext4." "i"
    blockdev --rereadpt ${DEVICE_USB}
    sfdisk ${DEVICE_USB} << EOF
,${SIZE_PRIMARY_PART},U,*
,${SIZE_SECONDARY_PART},${TYPE_SECONDARY_PART}
EOF
    sync && sync
    log "Formatto la prima partizione." "i"
    mkfs.fat -F 32 ${DEVICE_USB}1
    log "Formatto la seconda partizione." "i"
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

########################################################################
# install_syslinux_to_usb:
########################################################################
function install_syslinux_to_usb() {
    if [ ${DEVICE_USB} ]; then
        log "Copio MBR sul device usb." "i"
        dd if=/usr/lib/SYSLINUX/mbr.bin of=${DEVICE_USB}
        mkdir -p ${PATH_TO_MOUNT}
        log "Monto la partizione ${DEVICE_USB}1 su ${PATH_TO_MOUNT}." "i"
        mount ${DEVICE_USB}1 ${PATH_TO_MOUNT}
        log "Creo la directory ${PATH_TO_MOUNT}${SYSLINUX_INST}" "i"
        mkdir -p ${PATH_TO_MOUNT}${SYSLINUX_INST}
        log "Install syslinux su ${DEVICE_USB}1" "i"
        syslinux -d ${SYSLINUX_INST} --install ${DEVICE_USB}1
    else
        log "Line:${LINENO} - Il device usb non è impostato." "f"
    fi
    log "Smonto la partizione ${DEVICE_USB}1." "i"
    umount ${DEVICE_USB}1
    log "Syslinux installato!" "i"
}

########################################################################
# copy_iso_to_usb:
########################################################################
function copy_files_to_usb() {
    FILE_TO_COPY=
    VALUE=0
    cd "${ARCHIVE}/${ROOT_DIR}/home/snapshot"
    for file in $(ls *.iso); do
        out=$(echo "${file//[!0-9]/ }"|xargs|cut -d' ' -f1)
        echo $out
        [[ $out -gt ${VALUE} ]] && VALUE=${out} && FILE_TO_COPY=${file}
    done
    cd "${ARCHIVE}"
    if [ ${FILE_TO_COPY} ]; then
        log "Monto la partizione ${DEVICE_USB}1 su ${PATH_TO_MOUNT}." "i"
        mount ${DEVICE_USB}1 ${PATH_TO_MOUNT}
        log "Copio la iso sul device usb" "i"
        mkdir -p ${ARCHIVE}/part1
        mount -o loop ${ARCHIVE}/${ROOT_DIR}/home/snapshot/${FILE_TO_COPY} ${ARCHIVE}/part1
        cp -va ${ARCHIVE}/part1/{isolinux,live} ${PATH_TO_MOUNT}/
        sync && sync
        umount ${ARCHIVE}/part1
        log "Copio syslinux.cfg" "i"        
        cp -va ${PATH_TO_MOUNT}${SYSLINUX_INST}/isolinux.cfg ${PATH_TO_MOUNT}${SYSLINUX_INST}/syslinux.cfg
        log "Smonto la partizione ${DEVICE_USB}1." "i"
        umount ${DEVICE_USB}1
    fi
}

########################################################################
# create_persistence_conf:
########################################################################
function create_persistence_conf() {
    log "Creo il punto di mount ${ARCHIVE}/part2" "i"
    mkdir -p ${ARCHIVE}/part2
    log "Monto la partizione ${DEVICE_USB}2" "i"
    mount ${DEVICE_USB}2 ${ARCHIVE}/part2
    cat > ${ARCHIVE}/part2/persistence.conf << EOF
        / union
EOF
    log "Smonto la partizione ${DEVICE_USB}2" "i"
    umount ${DEVICE_USB}2
}


########################################################################
# create_pendrive_live:
########################################################################
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
    log "Cancello la pennetta e ricreo le partizioni." "i"
    create_partitions
    copy_files_to_usb
    install_syslinux_to_usb
    install_refind
    create_persistence_conf
}

########################################################################
# linux_firmware:
########################################################################
function linux_firmware() {
    if [ $1 ]; then
        FIRMWARE_DIR=$ARCHIVE/linux-firmware
        if [ -d $FIRMWARE_DIR ]; then
            cd $FIRMWARE_DIR
            git pull
            if [ $? != '0' ]; then
                rm -R $FIRMWARE_DIR
                git clone git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git $FIRMWARE_DIR
            fi
            cd $ARCHIVE
        else
            git clone git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git $FIRMWARE_DIR
        fi
        cp -var $FIRMWARE_DIR/* $1/lib/firmware/
    fi
}

########################################################################
# check_root:
########################################################################
function check_root() {
    if [ ${UID} != 0 ]; then
        echo "Devi essere root per eseguire questo script."
        exit
    fi
}

########################################################################
# init:
########################################################################
function init() {
    echo "init"
    check_root
    [ $CLEAN = 1 ] && rm $VERBOSE -R $ROOT_DIR
    if [ -d ${ROOT_DIR} ]; then
        mkdir -p ${ROOT_DIR}
    fi
    if [ ! -d "${TEMP_REPOSITORY}" ]; then
        mkdir -p "${TEMP_REPOSITORY}"
    fi
    if [ ! -d ${ROOT_DIR}/var/cache/apt/archives ]; then
        mkdir -p ${ROOT_DIR}/var/cache/apt/archives
    fi
    if ! mount | grep ${ROOT_DIR}/var/cache/apt/archives; then
        mount $VERBOSE --bind ${TEMP_REPOSITORY} ${ROOT_DIR}/var/cache/apt/archives
    fi
}

########################################################################
# compile_debootstrap:
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
# ctrl_c:
########################################################################
trap ctrl_c SIGINT
ctrl_c() {
    echo "*** CTRL-C pressed***"
    unbind ${ROOT_DIR}
    if mount | grep ${ROOT_DIR}/var/cache/apt/archives; then
        umount -l ${VERBOSE} ${ROOT_DIR}/var/cache/apt/archives
    fi
    exit -1
}

########################################################################
# bind:
########################################################################
function bind() {
    if [ $1 ]; then
        dirs="dev dev/pts proc sys run"
        for dir in $dirs; do
            if ! mount | grep $1/$dir; then
                mount $VERBOSE --bind /$dir $1/$dir
            fi
        done
    fi
}

########################################################################
# unbind:
########################################################################
function unbind() {
    if [ $1 ]; then
        dirs="run sys proc dev/pts dev"
        for dir in $dirs; do
            if mount | grep $1/$dir; then
                umount -l $VERBOSE $1/$dir
            fi
        done
    fi
}

########################################################################
# log:
########################################################################
function log() {
    [[ ! $2 ]] && echo "ERRORE!!!" && exit
    case $2 in
        i | info)
            echo -e "INFO: $1" | tee -a $LOG 1>&2
            ;;
        w | warning)
            echo -e "WARNING: $1" | tee -a $LOG 1>&2
            ;;
        d | debug)
            echo -e "DEBUG: $1" | tee -a $LOG 1>&2
            ;;
        f | FATAL)
            echo -e "<<<<FATAL!!!: $1" | tee -a $LOG 1>&2
            exit -1
            ;;
    esac
    #echo -e "Line:$1 - $(date):\n\tstage $STAGE\n\tdistribution $DIST\n\troot directory $ROOT_DIR\n\tkeyboard $KEYBOARD\n\tlocale $LOCALE\n\tlanguage $LANG\n\ttimezone $TIMEZONE\n\tdesktop $DE\n\tarchitecture $ARCH">>$LOG
}

########################################################################
# update: 
########################################################################
function update() {
    if [ $1 ]; then
        echo -e $APT_REPS > $1/etc/apt/sources.list
        chroot $1 apt update
    fi
}

########################################################################
# upgrade:
########################################################################
function upgrade() {
    if [ $1 ]; then
        bind $1
        hook_create_fake_start_stop_daemon
        chroot $1 /bin/bash -c "DEBIAN_FRONTEND=$FRONTEND apt-get $APT_OPTS dist-upgrade"
        hook_restore_fake_start_stop_daemon
        unbind $1
    fi
}

########################################################################
# upgrade_packages:
########################################################################
function upgrade_packages() {
    if [ $1 ]; then
        bind $1
        hook_create_fake_start_stop_daemon
        chroot $1 /bin/bash -c "DEBIAN_FRONTEND=$FRONTEND apt-get $APT_OPTS install $PACKAGES"
        hook_restore_fake_start_stop_daemon
        unbind $1
    fi
}

########################################################################
# add_user:
########################################################################
function add_user() {
    if [ $1 ]; then
        chroot $1 useradd -m -p $CRYPT_PASSWD -s $SHELL $USERNAME
    fi
}

########################################################################
# set_locale
########################################################################
function set_locale() {
    if [ $1 ]; then
        echo $TIMEZONE > $1/etc/timezone
        LINE=$(cat $1/etc/locale.gen|grep "${LOCALE}")
        sed -i "s/${LINE}/${LOCALE}/" $1/etc/locale.gen
        chroot $1 locale-gen
        chroot $1 update-locale LANG=${LANG}
        LINE=$(cat $1/etc/default/keyboard|grep "XKBLAYOUT")
        sed -i "s/${LINE}/XKBLAYOUT=\"${KEYBOARD}\"/" $1/etc/default/keyboard
    fi
}

########################################################################
# snapshot : necessita di montare le dirs dev sys run etc.
########################################################################
function create_snapshot() {
    if [ $1 ]; then
        cp -v $PATH_SCRIPTS/snapshot.sh $1/tmp/
        chmod -v +x $1/tmp/snapshot.sh
        cmd="/tmp/snapshot.sh -d Devuan -k $KEYBOARD -l $LOCALE -u $USERNAME -s $SNAPSHOT"
        if mount | grep ${ROOT_DIR}/var/cache/apt/archives; then
            umount -l $VERBOSE ${ROOT_DIR}/var/cache/apt/archives
        fi
        chroot $1 /bin/bash -c "${cmd}"
    fi
}

########################################################################
# set_distro_env:
########################################################################
function set_distro_env() {
    if [ $DIST = "ascii" ]; then
        APT_REPS="deb http://pkgmaster.devuan.org/merged ascii main contrib non-free\n"
    elif [ $DIST = "beowulf" ]; then
        APT_REPS="deb http://pkgmaster.devuan.org/merged ascii main contrib non-free\ndeb http://pkgmaster.devuan.org/merged beowulf main contrib non-free\n"
    fi
    if [ $COMPILE_BOOTSTRAP = 1 ]; then
        compile_debootstrap
    else
        apt-get install debootstrap
    fi
}

########################################################################
# ascii:
########################################################################

function ascii() {
    DIST="ascii"
    check_script
    fase1 $ROOT_DIR
    fase2 $ROOT_DIR
    fase3 $ROOT_DIR
    fase4 $ROOT_DIR
}

########################################################################
# beowulf:
########################################################################

function beowulf() {
    DIST="beowulf"
    check_script
    fase1 $ROOT_DIR
    fase2 $ROOT_DIR
    fase3 $ROOT_DIR
    fase4 $ROOT_DIR
}

########################################################################
# fase1:
########################################################################
function fase1() {
    if [ $1 ]; then
        log "Line:${LINENO} - $(date):\n\tstage $STAGE\n\tdistribution $DIST\n\troot directory $ROOT_DIR\n\tkeyboard $KEYBOARD\n\tlocale $LOCALE\n\tlanguage $LANG\n\ttimezone $TIMEZONE\n\tdesktop $DE\n\tarchitecture $ARCH" "i"
        $DEBOOTSTRAP_BIN --verbose --arch=$ARCH ${DIST} $1 $MIRROR
        if [ $? -gt 0 ]; then
            log "Big problem!!!" "f"
        fi
    fi
}

########################################################################
# fase2:
########################################################################
function fase2() {
    if [ $1 ]; then
        bind $1
        update $1
        upgrade $1
        hook_hostname $1
        chroot $1 /bin/bash -c "DEBIAN_FRONTEND=$FRONTEND apt-get $APT_OPTS autoremove --purge"
        hook_create_fake_start_stop_daemon $1
        chroot $1 /bin/bash -c "DEBIAN_FRONTEND=$FRONTEND apt-get $APT_OPTS install $INCLUDES"
        if [ $? -gt 0 ]; then
            unbind $1
            log "Line:${LINENO} BIG PROBLEM!!!" "f"
        fi
        linux_firmware $1
        add_user $1
        set_locale $1
        chroot $1 /bin/bash -c "DEBIAN_FRONTEND=$FRONTEND apt-get $APT_OPTS install $INSTALL_DISTRO_DEPS"
        if [ $? -gt 0 ]; then
            unbind $1
            log "Line:${LINENO} BIG PROBLEM!!!" "f"
        fi
        hook_install_distro $1
        unbind $1
    fi
}

########################################################################
# fase3:
########################################################################
function fase3() {
    if [ $1 ]; then
        bind $1
        chroot $1 dpkg --configure -a --force-confdef,confnew
        chroot $1 /bin/bash -c "DEBIAN_FRONTEND=$FRONTEND apt-get $APT_OPTS install $PACKAGES"
        if [ $? -gt 0 ]; then
            unbind $1
            log "Line:${LINENO} BIG PROBLEM!!!" "f"
        fi
        hook_synaptics $1
        hook_restore_fake_start_stop_daemon $1
        unbind $1
    fi
}

########################################################################
# fase4:
########################################################################
function fase4() {
    if [ $1 ]; then
        update $1
        bind $1
        upgrade $1
        if [ $? -gt 0 ]; then
            unbind $1
            log "Line:${LINENO} BIG PROBLEM!!!" "f"
        fi
        chroot $1 apt-get $APT_OPTS autoremove --purge
        chroot $1 dpkg --purge -a
        [ $CLEAN_SNAPSHOT = 1 ] && rm $VERBOSE $ROOT_DIR/home/snapshot/* $ROOT_DIR/home/snapshot/filesystem.squashfs-*
        create_snapshot $1
        unbind $1
    fi
}

########################################################################
# HOOKS
########################################################################
########################################################################
# update_hooks:
########################################################################
function update_hooks() {
    if [ $1 ]; then
        hook_install_distro $1
        hook_hostname $1
        hook_synaptics $1
    fi
}

########################################################################
# hook_create_fake_start_stop_daemon:
########################################################################
function hook_create_fake_start_stop_daemon() {
    if [ $1 ]; then
        if [ ! -e /sbin/start-stop-daemon.orig ]; then
            chroot $1 cp -v /sbin/start-stop-daemon /sbin/start-stop-daemon.orig
            chroot $1 touch /sbin/start-stop-daemon
            chroot $1 chmod +x /sbin/start-stop-daemon
        fi
    fi
}

########################################################################
# hook_restore_fake_start_stop_daemon:
########################################################################
function hook_restore_fake_start_stop_daemon() {
    if [ $1 ]; then
        if [ -e /sbin/start-stop-daemon.orig ]; then
            chroot $1 cp -vf /sbin/start-stop-daemon.orig /sbin/start-stop-daemon
            chroot $1 rm -vf /sbin/start-stop-daemon.orig
        fi
    fi
}

########################################################################
# hook_install_distro:
########################################################################
function hook_install_distro() {
    if [ $1 ]; then
        TMP="/tmp/scripts"
        GIT_DIR="scripts"
        chroot $1 mkdir -p $TMP
        chroot $1 git clone https://github.com/mortaromarcello/scripts.git $TMP/$GIT_DIR
        mkdir -p $1/usr/local/share/install_distro
        chroot $1 cp $VERBOSE -a $TMP/$GIT_DIR/install_distro.py /usr/local/share/install_distro/
        chroot $1 cp $VERBOSE -a $TMP/$GIT_DIR/install_distro.png /usr/local/share/install_distro/
        chroot $1 cp $VERBOSE -a $TMP/$GIT_DIR/install_distro /usr/local/bin/
        cat > $1/usr/share/applications/install_distro.desktop <<EOF
[Desktop Entry]
Encoding=UTF-8
Type=Application
Terminal=false
Exec=sudo /usr/local/bin/install_distro
Name=Install Distro
Comment=
Categories=GTK;System;Settings;
Icon=/usr/local/share/install_distro/install_distro.png
EOF
        chroot $1 rm -R -f $VERBOSE ${TMP}
    fi
}

########################################################################
# hook_synaptics:
########################################################################
function hook_synaptics() {
    if [ $1 ]; then
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
    fi
}

########################################################################
# hook_hostname:
########################################################################
function hook_hostname() {
    if [ $1 ]; then
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
    fi
}

########################################################################
# END HOOKS
########################################################################
########################################################################
# check_script:
########################################################################
function check_script() {
    [[ $DEBUG = "yes" ]] && set -v -x
    [[ "${DEVICE_USB}" ]] && is_removable
    if [ $DIST != ascii ] && [ $DIST != beowulf ]; then
        DIST=ascii
    fi
    if [ $ARCH != i386 ] && [ $ARCH != amd64 ]; then
        ARCH=amd64
    fi
    if [ $DE != "mate" ] && [ $DE != "xfce" ] && [ $DE != "lxde" ] && [ $DE != "kde" ] && [ $DE != "cinnamon" ] && [ $DE != "gnome" ] && [ $DE != "lxqt" ]; then
        DE="xfce"
    fi
    if [ ! ${SNAPSHOT} ]; then
        SNAPSHOT=${ROOT_DIR}-${DE}
    fi
    case $DIST in
        "ascii" | "beowulf")
            PACKAGES="yad gtk3-engines-breeze $PACKAGES"
            ;;
        *)
            ;;
    esac
    case $DE in
        "mate")
            PACKAGES_FILE="packages_mate"
            ;;
        "xfce")
            PACKAGES_FILE="packages_xfce"
            ;;
        "lxde")
            PACKAGES_FILE="packages_lxde"
            ;;
        "kde")
            PACKAGES_FILE="packages_kde"
            ;;
        "cinnamon")
            PACKAGES_FILE="packages_cinnamon"
            ;;
        "gnome")
            PACKAGES_FILE="packages_gnome"
            ;;
        "lxqt")
            PACKAGES_FILE="packages_lxqt"
            ;;
    esac
    # alternativa
    if [ -e ${PACKAGES_FILE} ]; then
        PACKAGES="$(cat ./${PACKAGES_FILE}) python-wxgtk3.0 python-parted task-$LANGUAGE iceweasel-l10n-$KEYBOARD $PACKAGES"
    else
        PACKAGES="python-wxgtk3.0 python-parted task-laptop task-$DE-desktop task-$LANGUAGE $PACKAGES"
    fi
    if [ -e packages_utility ]; then
        PACKAGES="$(cat packages_utility) $PACKAGES"
    fi
    set_distro_env
    if [ ${TYPE_SECONDARY_FS} = "exfat" ]; then
        TYPE_SECONDARY_PART=7
    elif [ ${TYPE_SECONDARY_FS} = "vfat" ]; then
        TYPE_SECONDARY_PART=c
    fi
    if [ -n $DEVICE_USB ]; then
        echo "device usb: $DEVICE_USB"
        echo "path to mount: $PATH_TO_MOUNT"
        echo "syslinux install path: $SYSLINUX_INST"
        echo "size primary partition: $SIZE_PRIMARY_PART"
        echo "size secondary filesystem: $SIZE_SECONDARY_PART"
        echo "tipo di  filesystem partizione secondaria: $TYPE_SECONDARY_FS"
        echo "tipo partizione secondaria: $TYPE_SECONDARY_PART"
    fi
    [[ ! -e /usr/bin/git ]] && apt-get -y install git
    [[ ! -e /sbin/MAKEDEV ]] && apt-get -y install makedev
    [[ ! -e /usr/bin/rpl ]] && apt-get -y install rpl
    [[ ! -e /usr/bin/uuencode ]] && apt-get -y install sharutils
    [[ ! -e /usr/bin/make ]] && apt-get -y install make
    echo "distribution: $DIST"
    echo "architecture: $ARCH"
    echo "desktop: $DE"
    echo "stage: $STAGE"
    echo "snapshot: $SNAPSHOT"
    echo "root: directory $ROOT_DIR"
    echo "locale: $LOCALE"
    echo "lang: $LANG"
    echo "language: $LANGUAGE"
    echo "keyboard: $KEYBOARD"
    echo "timezone: $TIMEZONE"
    echo -e "deb repository: $APT_REPS"
    echo "packages: $PACKAGES"
    echo "Script verificato. OK."
}

########################################################################
# help:
########################################################################
function help() {
  echo -e "
${0} <opzioni>
Crea una live Devuan
  -a | --arch <architecture>             :tipo di architettura.
  -c | --clean                           :cancella la cartella root.
  -d | --distribuition <dist>            :tipo di distribuzione.
  -D | --desktop <desktop>               :tipo di desktop mate, xfce (default), lxde o kde.
  -h | --help                            :Stampa questa messaggio.
  -k | --keyboard                        :Tipo di tastiera (default 'it').
  -l | --locale                          :Tipo di locale (default 'it_IT.UTF-8 UTF-8').
  -L | --lang                            :Lingua (default 'it_IT.UTF-8').
  -n | --hostname                        :Nome hostname (default 'devuan').
  -s | --stage <stage>                   :Numero fase:
        1) crea la base del sistema;
        2) setta lo user, hostname e la lingua e i pacchetti indispensabili;
        3) installa pacchetti aggiuntivi e il desktop;
        4) installa lo script d'installazine e crea la iso;
        min) fase 1 + fase 2 + fase 4;
        iso-update) aggiorna la iso;
        ascii)
        beowulf) crea le rispettive iso delle distribuzioni;
  -sb| --snapshot_basename               : Nome base dello snapshot.
  -r | --root-dir <dir>                  :Directory della root
  -T | --timezone <timezone>             :Timezone (default 'Europe/Rome').
  -u | --user                            :Nome utente.
"
}

########################################################################
# end:
########################################################################
function end() {
    echo "end"
    if mount | grep ${ROOT_DIR}/var/cache/apt/archives; then
        umount -l $VERBOSE ${ROOT_DIR}/var/cache/apt/archives
    fi
}

########################################################################
# main:
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
        -cb | --compile-bootstrap)
            shift
            COMPILE_BOOTSTRAP=1
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
# device-usb
        -du | --device-usb)
            shift
            DEVICE_USB=${1}
            ;;
        -pm | --path-to-mount)
            shift
            PATH_TO_MOUNT=${1}
            ;;
        -pi | --path-to-install-syslinux)
            shift
            SYSLINUX_INST=${1}
            ;;
        -sb | snapshot_basename)
            shift
            SNAPSHOT=${1}
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
            shift
            ;;
    esac
done

init

case $STAGE in
    "")
        #;&
        help
        ;;
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
        hook_restore_fake_start_stop_daemon $ROOT_DIR
        fase4 $ROOT_DIR
        ;;
    ascii)
        ascii
        ;;
    beowulf)
        beowulf
        ;;
    iso-update)
        check_script
        update_hooks $ROOT_DIR
        upgrade_packages $ROOT_DIR
        fase4 $ROOT_DIR
        ;;
    upgrade)
        check_script
        bind $ROOT_DIR
        update $ROOT_DIR
        upgrade $ROOT_DIR
        unbind $ROOT_DIR
        ;;
    create-pendrive)
        check_script
        [[ ${DEVICE_USB} ]] && create_pendrive_live
        ;;
    *)
        ;;
esac

end
