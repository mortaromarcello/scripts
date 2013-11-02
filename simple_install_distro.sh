#!/bin/bash
#
# semplice script di installazione
#
#-----------------------------------------------------------------------
#  inserire qui le label

DISTRO="distro"
INST_PARTITION="/dev/sda1"
HOME_PARTITION=
INST_ROOT_DIRECTORY="/mnt/${DISTRO}"
TYPE_FS="ext4"
USER=
CRYPT_PASSWORD=

#-----------------------------------------------------------------------

function check_root() {
  if [ $UID != 0 ]; then
    echo "Devi essere root per eseguire questo script."
    exit
  fi
}

function check_hd() {
	echo "work"
}

get_info() {
  echo "Partizione di installazione (root):" $INST_PARTITION
  if [ ! -z $HOME_PARTITION ]; then
    echo "Partizione di home                :" $HOME_PARTITION
  fi
  echo "Tipo di file system               :" $TYPE_FS
  if [ ! -z $USER ]; then
    echo "Username                          :" $USER
  fi
  if [ ! -z $CRYPT_PASSWORD ]; then
    echo "Password criptata                 :" $CRYPT_PASSWORD
  fi
}

function run_inst {
    read -p "Attenzione! la partizione sarà formattata! (Ctrl-c per abortire)"
    mkfs -t $TYPE_FS $INST_PARTITION
    mkdir -p $INST_ROOT_DIRECTORY
    mount $INST_PARTITION $INST_ROOT_DIRECTORY
    if [ -z $HOME_PARTITION ]; then
      mkfs -t $TYPE_FS $HOME_PARTITION
      mkdir -p "${INST_ROOT_DIRECTORY}/home"
      mount $HOME_PARTITION "$INST_ROOT_DIRECTORY/home"
    fi
    for dir in bin boot etc lib opt sbin srv usr var; do
      cp -av "/$dir" "$INST_ROOT_DIRECTORY"
    done
    if [ -z $USER ]; then
      read -p "Digita la username: " USER
    fi
    if [ -z $CRYPT_PASSWORD ]; then
      read -s -p "Digita la password: " USER_PASSWORD
      CRYPT_PASSWORD=$(perl -e 'print crypt($ARGV[0], "password")' $USER_PASSWORD)
    fi
    #chroot $INST_ROOT_DIRECTORY useradd -m -p $CRYPT_PASSWORD $USER
    #[ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!";exit
}

#------------------------------------------------------------------------

until [ -z "$1" ]
do
  case $1 in
    -i | --inst-partition)
      shift
      INST_PARTITION=$1
      
      ;;
    -t | --type-fs)
      shift
      TYPE_FS=$1
      ;;
    -h | --home-partition)
      shift
      HOME_PARTITION=$1
      
      ;;
    -u | --user)
      shift
      USER=$1
      ;;
    -c | --crypt-password)
      shift
      CRYPT_PASSWORD=$1
      ;;
    *)
      shift
      ;;
  esac
done

check_root
get_info
