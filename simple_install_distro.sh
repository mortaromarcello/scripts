#!/bin/bash
#
# semplice script di installazione
#
#-----------------------------------------------------------------------
#
#-----------------------------------------------------------------------

function help() {
  echo -e "
${0} <opzioni>
Installa una live su un disco.
  -c | --crypt-password <password>       :Password cifrata utente.
  -C | --crypt-root-password <password>  :Password cifrata root.
  -d | --inst-drive <drive>              :Drive di installazione per grub.
  -f | --format-home <si/no>             :Se 'si', formatta la partizione home.
  -h | --help                            :Stampa questa messaggio.
  -H | --home-partition <partition>      :Partizione di home.
  -i | --inst-root-directory <directory> :Directory di installazione (default '/mnt/distro').
  -l | --live-user <user>                :User live (default 'live-user)
  -r | --root-partition <partition>      :Partizione di root (default '/dev/sda1')
  -s | --swap-partition <partition>      :Partizione di swap.
  -t | --type-fs <type fs>               :Tipo di file system (default 'ext4')
  -u | --user                            :Nome utente.
"
}

function check_root() {
  if [ ${UID} != 0 ]; then
    echo "Devi essere root per eseguire questo script."
    exit
  fi
}

#

DISTRO="distro"
INST_DRIVE="/dev/sda"
ROOT_PARTITION="/dev/sda1"
UUID_ROOT_PARTITION=
HOME_PARTITION=
UUID_HOME_PARTITION=
FORMAT_HOME="no"
SWAP_PARTITION=
UUID_SWAP_PARTITION=
INST_ROOT_DIRECTORY="/mnt/${DISTRO}"
TYPE_FS="ext4"
USER=
CRYPT_PASSWORD=
CRYPT_ROOT_PASSWORD=
LIVE_USER="live-user"
YES_NO="no"

put_info() {
  echo "Partizione di installazione (root):" ${ROOT_PARTITION}
  echo "UUID                              :" ${UUID_ROOT_PARTITION}
  if [ ! -z ${HOME_PARTITION} ]; then
    echo "Partizione di home                :" ${HOME_PARTITION}
    echo "UUID                              :" ${UUID_HOME_PARTITION}
    echo "Formattare home                   :" ${FORMAT_HOME}
  fi
  echo "Tipo di file system               :" ${TYPE_FS}
  if [ ! -z ${SWAP_PARTITION} ]; then
    echo "Partizione di swap                :" ${SWAP_PARTITION}
    echo "UUID                              :" ${UUID_SWAP_PARTITION}
  fi
  echo "Directory di installazione        :" ${INST_ROOT_DIRECTORY}
  if [ ! -z ${USER} ]; then
    echo "Username                          :" ${USER}
  fi
  if [ ! -z ${CRYPT_PASSWORD} ]; then
    echo "Password criptata                 :" ${CRYPT_PASSWORD}
  fi
  echo "Drive di installazione di grub    :" ${INST_DRIVE}
  if [ ! -z ${CRYPT_ROOT_PASSWORD} ]; then
    echo "Password root criptata            :" ${CRYPT_ROOT_PASSWORD}
  fi
  echo "Live user                         :" ${LIVE_USER}
}

function create_root_and_mount_partition() {
  IS_MOUNTED=$(mount|grep ${ROOT_PARTITION})
  if [ ! -z $IS_MOUNTED ]; then
    echo "La partizione è montata. Esco."
    exit
  fi
  if [ ${YES_NO} = "no" ]; then
    read -p "Attenzione! la partizione sarà ${ROOT_PARTITION} formattata! Continuo?(si/no): " YES_NO
  fi
  if [ ${YES_NO} = "no" ] || [ -z ${YES_NO} ]; then
    exit
  fi
  mkfs -t ${TYPE_FS} ${ROOT_PARTITION}
  UUID_ROOT_PARTITION=$(blkid -o value -s UUID ${ROOT_PARTITION})
  mkdir -p ${INST_ROOT_DIRECTORY}
  mount ${ROOT_PARTITION} ${INST_ROOT_DIRECTORY}
}

function create_home_and_mount_partition() {
  IS_MOUNTED=$(mount|grep ${HOME_PARTITION})
  if [ ! -z $IS_MOUNTED ]; then
    echo "La partizione è montata. Esco."
    exit
  fi
  if [ ! -z ${HOME_PARTITION} ]; then
    if [ ${FORMAT_HOME} = "si" ]; then
      if [ ${YES_NO} = "no" ]; then
        read -p "Attenzione! la partizione ${HOME_PARTITION} sarà formattata! Continuo?(si/no): " YES_NO
      fi
      if [ ${YES_NO} = "no" ] || [ -z ${YES_NO} ]; then
        exit
      fi
      mkfs -t ${TYPE_FS} ${HOME_PARTITION}
      UUID_HOME_PARTITION=$(blkid -o value -s UUID ${HOME_PARTITION})
    fi
    mkdir -p ${INST_ROOT_DIRECTORY}/home
    mount ${HOME_PARTITION} ${INST_ROOT_DIRECTORY}/home
  fi
}

function copy_root() {
  for dir in bin boot etc lib opt sbin srv usr var; do
    cp -av /${dir} ${INST_ROOT_DIRECTORY}
  done
}

function add_user() {
  if [ -z ${USER} ]; then
    read -p "Digita la username: " USER
  fi
  if [ -z ${CRYPT_PASSWORD} ]; then
    read -s -p "Digita la password: " USER_PASSWORD
    CRYPT_PASSWORD=$(perl -e 'print crypt($ARGV[0], "password")' ${USER_PASSWORD})
  fi
  chroot ${INST_ROOT_DIRECTORY} useradd -m -p $CRYPT_PASSWORD $USER
  if [ $? -eq 0 ]; then echo "User has been added to system!" 
  else
    echo "Failed to add a user!";
    exit
  fi
}

function change_root_password() {
  if [ -z ${CRYPT_ROOT_PASSWORD} ]; then
    read -p "Digita la password per l'amministratore root: " ROOT_PASSWORD
    CRYPT_ROOT_PASSWORD=$(perl -e 'print crypt($ARGV[0], "password")' ${ROOT_PASSWORD})
    
  fi
  echo "root:${CRYPT_ROOT_PASSWORD}" | chpasswd -e
}

function remove_user_live() {
  deluser --remove-all-files ${LIVE_USER}
}

create_fstab() {
  cat > ${INST_ROOT_DIRECTORY}/etc/fstab <<EOF
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point> <type> <options> <dump> <pass>
proc /proc proc defaults 0 0
UUID=${UUID_ROOT_PARTITION} / ${TYPE_FS} errors=remount-ro 0 1
EOF
  if [ ! -z ${HOME_PARTITION} ]; then
    cat >> ${INST_ROOT_DIRECTORY}/etc/fstab <<EOF
UUID=${UUID_HOME_PARTITION} /home ${TYPE_FS} defaults 0 2
EOF
  fi
  if [ ! -z ${SWAP_PARTITION} ]; then
  cat >> ${INST_ROOT_DIRECTORY}/etc/fstab <<EOF
UUID=${UUID_SWAP_PARTITION} none swap sw 0 0
EOF
  fi
}

function install_grub() {
  for dir in dev proc sys; do
    mount -B /${dir} ${INST_ROOT_DIRECTORY}
  done
  chroot ${INST_ROOT_DIRECTORY} grub-install --no-floppy ${INST_DRIVE}
  for dir in dev proc sys; do
    umount ${INST_ROOT_DIRECTORY}/$dir
  done
}

function run_inst {
  put_info
  create_root_and_mount_partition
  create_home_and_mount_partition
  copy_root
  add_user
  change_root_password
  remove_user_live
  create_fstab
  #install_grub
}

#------------------------------------------------------------------------
until [ -z "${1}" ]
do
  case ${1} in
    -c | --crypt-password)
      shift
      CRYPT_PASSWORD=${1}
      ;;
    -C | --crypt-root-password)
      shift
      CRYPT_ROOT_PASSWORD=${1}
      ;;
    -d | --inst-drive)
      shift
      INST_DRIVE=${1}
      ;;
    -f | --format-home)
      shift
      FORMAT_HOME="si"
      ;;
    -h | --help)
      shift
      help
      exit
      ;;
    -H | --home-partition)
      shift
      HOME_PARTITION=${1}
      UUID_HOME_PARTITION=$(blkid -o value -s UUID ${HOME_PARTITION})
      ;;
    -i | --inst-root-directory)
      shift
      INST_ROOT_DIRECTORY=${1}
      ;;
    -l | --live-user)
      shift
      LIVE_USER=${1}
      ;;
    -r | --root-partition)
      shift
      ROOT_PARTITION=${1}
      ;;
    -s | --swap-partition)
      shift
      SWAP_PARTITION=${1}
      UUID_SWAP_PARTITION=$(blkid -o value -s UUID ${SWAP_PARTITION})
      ;;
    -t | --type-fs)
      shift
      TYPE_FS=${1}
      ;;
    -u | --user)
      shift
      USER=${1}
      ;;
    -y | --yes)
      shift
      YES_NO="si"
      ;;
    *)
      shift
      ;;
  esac
done

check_root
run_inst

