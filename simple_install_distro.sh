#!/usr/bin/env bash
# semplice script di installazione
#
#
#-----------------------------------------------------------------------
#  inserire qui le label
DISTRO="distro"
INST_PARTITION=
INST_ROOT_DIRECTORY="/mnt/${DISTRO}"
LIST_CP_DIRECTORY=(bin boot etc lib opt sbin srv usr var)
TYPE_FS="ext4"
USER=

#-----------------------------------------------------------------------

check_hd() {
	echo "work"
}

#get_info() {
#	echo "work"
#    INST_PARTITION="/dev/sda7"  
#    USER="user"
#    USER_PASSWORD="password"
#}

cp_distro() {
	echo "work"
    for dir in $LIST_CP_DIRECTORY; do
        cp -a "/$dir" "$INST_ROOT_DIRECTORY"
    done
}

setup_distro {
    echo "work"
    read -p "Digita la partizione d'installazione(/dev/sda1):" INST_PARTITION
    read -p "Digita il tipo di file system (ext2/3/4):" TYPE_FS
    read -p "Attenzione! la partizione sarà formattata! (Ctrl-c per abortire)"
    mkfs -t $TYPE_FS $INST_PARTITION
    mount $INST_PARTITION $INST_ROOT_DIRECTORY
    if [ $? -ne 0 ]; then
      echo "Problemi!!!"
      exit
    fi
    mkdir -p $INST_ROOT_DIRECTORY
    cd $INST_ROOT_DIRECTORY
    mount -t proc proc proc/
    mount -t sysfs sys sys/
    mount -o bind /dev dev/
    mount -t devpts pts dev/pts/
    chroot . /bin/bash
}

function add_user() {
  read -p "Digita la username: " USER
  read -s -p "Digita la password: " USER_PASSWORD
  pass=$(perl -e 'print crypt($ARGV[0], "password")' $USER_PASSWORD)
  useradd -m -p $pass $USER
  [ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!";exit
}

#------------------------------------------------------------------------
check_hd
setup_distro
cp_distro
