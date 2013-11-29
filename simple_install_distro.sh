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
"
}

function check_root() {
  if [ ${UID} != 0 ]; then
    echo "Devi essere root per eseguire questo script."
    exit
  fi
}

#  inserire qui le label

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

function check_hd() {
	echo "work"
}

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
    echo "Partizione di swap               :" ${SWAP_PARTITION}
    echo "UUID                             :" ${UUID_SWAP_PARTITION}
  fi
  echo "Directory di installazione        :" ${INST_ROOT_DIRECTORY}
  if [ ! -z ${USER} ]; then
    echo "Username                          :" ${USER}
  fi
  if [ ! -z ${CRYPT_PASSWORD} ]; then
    echo "Password criptata                 :" ${CRYPT_PASSWORD}
  fi
  echo "Drive di installazione di grub    :" ${INST_DRIVE}
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

function run_inst {
    read -p "Attenzione! la partizione sarà ${ROOT_PARTITION} formattata! (Ctrl-c per abortire)"
    mkfs -t ${TYPE_FS} ${ROOT_PARTITION}
    UUID_ROOT_PARTITION="$(blkid -o value -s UUID ${ROOT_PARTITION})"
    mkdir -p ${INST_ROOT_DIRECTORY}
    mount ${ROOT_PARTITION} ${INST_ROOT_DIRECTORY}
    if [ ! -z ${HOME_PARTITION} ]; then
      if [ ${FORMAT_HOME} = "si" ]; then
      read -p "Attenzione! la partizione ${HOME_PARTITION} sarà formattata! (Ctrl-c per abortire)"
        mkfs -t ${TYPE_FS} ${HOME_PARTITION}
        UUID_HOME_PARTITION="$(blkid -o value -s UUID ${HOME_PARTITION})"
      fi
      mkdir -p "${INST_ROOT_DIRECTORY}/home"
      mount ${HOME_PARTITION} "${INST_ROOT_DIRECTORY}/home"
    fi
    for dir in bin boot etc lib opt sbin srv usr var; do
      cp -av "/${dir}" "${INST_ROOT_DIRECTORY}"
    done
    if [ -z ${USER} ]; then
      read -p "Digita la username: " USER
    fi
    if [ -z ${CRYPT_PASSWORD} ]; then
      read -s -p "Digita la password: " USER_PASSWORD
      CRYPT_PASSWORD=$(perl -e 'print crypt($ARGV[0], "password")' ${USER_PASSWORD})
    fi
    chroot ${INST_ROOT_DIRECTORY} useradd -m -p ${CRYPT_PASSWORD $USER}
    [ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!";exit
    create_fstab
    grub-install --boot-directory=${INST_ROOT_DIRECTORY}/boot/grub --no-floppy ${INST_DRIVE}
}

#------------------------------------------------------------------------

until [ -z "${1}" ]
do
  case ${1} in
    -r | --root-partition)
      shift
      ROOT_PARTITION=${1}
      ;;
    -t | --type-fs)
      shift
      TYPE_FS=${1}
      ;;
    -H | --home-partition)
      shift
      HOME_PARTITION=${1}
      UUID_HOME_PARTITION="$(blkid -o value -s UUID ${HOME_PARTITION})"
      ;;
    -f | --format-home)
      shift
      FORMAT_HOME="si"
      ;;
    -u | --user)
      shift
      USER=${1}
      ;;
    -c | --crypt-password)
      shift
      CRYPT_PASSWORD=${1}
      ;;
    -d | --inst-drive)
      shift
      INST_DRIVE=${1}
      ;;
    -s | --swap-partition)
      shift
      SWAP_PARTITION=${1}
      UUID_SWAP_PARTITION="$(blkid -o value -s UUID ${SWAP_PARTITION})"
      ;;
    -i | --inst-root-directory)
      shift
      INST_ROOT_DIRECTORY=${1}
      ;;
    -h | --help)
      shift
      help
      exit
      ;;
    *)
      shift
      ;;
  esac
done
check_root
put_info
