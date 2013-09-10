#!/bin/bash
# semplice script di installazione
#
#
#-----------------------------------------------------------------------
#  inserire qui le label
DISTRO="distro"
INST_PARTITION="/dev/sda1"
HOME_PARTITION="/dev/sda2"
INST_ROOT_DIRECTORY="/mnt/${DISTRO}"
LIST_CP_DIRECTORY=(bin boot etc lib opt sbin srv usr var)
TYPE_FS="ext4"

#-----------------------------------------------------------------------

function check_hd() {
	echo "work"
}

get_info() {
  echo "Partizione di installazione (root):" $INST_PARTITION
  echo "Partizione di home                :" $HOME_PARTITION
  echo "Tipo di file system               :" $TYPE_FS
  echo "Username                          :" $USER
  echo "Password criptata                 :" $CRYPT_PASSWORD
}

function cp_distro() {
	echo "work"
    for dir in $LIST_CP_DIRECTORY; do
        cp -a "/$dir" "$INST_ROOT_DIRECTORY"
    done
}

function setup_distro {
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
  if [ -z $USER ]; then
    read -p "Digita la username: " USER
  fi
  if [ -z $CRYPT_PASSWORD ]; then
    read -s -p "Digita la password: " USER_PASSWORD
    CRYPT_PASSWORD=$(perl -e 'print crypt($ARGV[0], "password")' $USER_PASSWORD)
  fi
  useradd -m -p $CRYPT_PASSWORD $USER
  [ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!";exit
}

#------------------------------------------------------------------------
#check_args
#check_hd
#setup_distro
#cp_distro
#echo ${#}

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
get_info

