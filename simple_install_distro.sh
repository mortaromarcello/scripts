#!/bin/bash
#
# semplice script di installazione
#
#-----------------------------------------------------------------------
#
#-----------------------------------------------------------------------

#

DEBUG="false"
FILE_DEBUG="./debug.txt"
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
YES_NO="no"
LOCALE="it_IT.UTF-8 UTF-8"
LANG="it_IT.UTF-8"
KEYBOARD="it"
HOSTNAME="debian"
ADD_GROUPS="cdrom,floppy,audio,dip,video,plugdev,fuse,scanner,bluetooth,netdev,android"
TIMEZONE="Europe/Rome"
SHELL_USER="/bin/bash"

#-----------------------------------------------------------------------

function help() {
  echo -e "
${0} <opzioni>
Installa la Live su un disco.
  -c | --crypt-password <password>       :Password cifrata utente.
  -C | --crypt-root-password <password>  :Password cifrata root.
  -d | --inst-drive <drive>              :Drive di installazione per grub.
  -D | --debug                           :Abilita il debug.
  -f | --format-home <si/no>             :Se 'si', formatta la partizione home.
  -F | --file-debug <file>               :Nome del file di debug (default './debug.txt').
  -g | --groups <group1,...,groupn>      :Gruppi addizionali a cui l'utente appartiene.
  -h | --help                            :Stampa questa messaggio.
  -H | --home-partition <partition>      :Partizione di home.
  -i | --inst-root-directory <directory> :Directory di installazione (default '/mnt/distro').
  -k | --keyboard                        :Tipo di tastiera (default 'it').
  -l | --locale                          :Tipo di locale (default 'it_IT.UTF-8 UTF-8').
  -L | --language                        :Lingua (default 'it_IT.UTF-8').
  -n | --hostname                        :Nome hostname (default 'debian').
  -r | --root-partition <partition>      :Partizione di root (default '/dev/sda1').
  -s | --swap-partition <partition>      :Partizione di swap.
  -S | --shell-user                      :Shell user (default '/bin/bash').
  -t | --type-fs <type fs>               :Tipo di file system (default 'ext4').
  -T | --timezone <timezone>             :Timezone (default 'Europe/Rome'.
  -u | --user                            :Nome utente.
  -y | --yes                             :Non interattivo.
"
}

function check_debug() {
  if [ ${DEBUG} = "true" ]; then
    echo -e "-----------------------------------------------------------------------\ndebug_info ${LINENO}:Debug iniziato:$(date)\n-----------------------------------------------------------------------" &>> ${FILE_DEBUG}
    echo "debug_info ${LINENO}:Debug abilitato." &>> ${FILE_DEBUG}
    echo -e "debug_info Variabili:
      DEBUG=${DEBUG}
      FILE_DEBUG=${FILE_DEBUG}
      DISTRO=${DISTRO}
      INST_DRIVE=${INST_DRIVE}
      ROOT_PARTITION=${ROOT_PARTITION}
      UUID_ROOT_PARTITION=${UUID_ROOT_PARTITION}
      HOME_PARTITION=${HOME_PARTITION}
      UUID_HOME_PARTITION=${UUID_HOME_PARTITION}
      FORMAT_HOME=${FORMAT_HOME}
      SWAP_PARTITION=${SWAP_PARTITION}
      UUID_SWAP_PARTITION=${UUID_SWAP_PARTITION}
      INST_ROOT_DIRECTORY=${INST_ROOT_DIRECTORY}
      TYPE_FS=${TYPE_FS}
      USER=${USER}
      CRYPT_PASSWORD=${CRYPT_PASSWORD}
      CRYPT_ROOT_PASSWORD=${CRYPT_ROOT_PASSWORD}
      YES_NO=${YES_NO}
      LOCALE=${LOCALE}
      LANG=${LANG}
      KEYBOARD=${KEYBOARD}
      HOSTNAME=${HOSTNAME}
      ADD_GROUPS=${ADD_GROUPS}
      TIMEZONE=${TIMEZONE}
      SHELL_USER=${SHELL_USER}
    " &>> ${FILE_DEBUG}
  else
    echo "Debug disabilitato."
  fi
}

function check_root() {
  if [ ${UID} != 0 ]; then
    echo "Devi essere root per eseguire questo script."
    [ ${DEBUG} = "true" ] && echo "debug_info ${LINENO}:exit" &>> ${FILE_DEBUG} || \
    exit
  fi
}

function check_script() {
  MESSAGE1="Con l'opzione -y deve essere specificato lo user, la password cryptata dello user e la password cryptata di root."
  if [ ${YES_NO} = "si" ] && [ -z ${USER} ]; then
    echo ${MESSAGE1}; exit
  fi
  if [ ${YES_NO} = "si" ] && [ -z ${CRYPT_PASSWORD} ]; then
    echo ${MESSAGE1}; exit
  fi
  if [ ${YES_NO} = "si" ] && [ -z ${CRYPT_ROOT_PASSWORD} ]; then
      echo ${MESSAGE1}; exit 
  fi
  echo "Script verificato. OK."
}

put_info() {
  echo "Debug abilitato                   :" ${DEBUG}
  echo "Partizione di installazione (root):" ${ROOT_PARTITION}
  #echo "UUID                              :" ${UUID_ROOT_PARTITION}
  if [ ! -z ${HOME_PARTITION} ]; then
    echo "Partizione di home                :" ${HOME_PARTITION}
    echo "UUID                              :" ${UUID_HOME_PARTITION}
    echo "Formattare home                   :" ${FORMAT_HOME}
  fi
  echo "Tipo di file system               :" ${TYPE_FS}
  if [ ! -z ${SWAP_PARTITION} ]; then
    echo "Partizione di swap                :" ${SWAP_PARTITION}
    #echo "UUID                              :" ${UUID_SWAP_PARTITION}
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
  echo "Locale                            :" ${LOCALE}
  echo "Tastiera                          :" ${KEYBOARD}
  echo "Lingua                            :" ${LANG}
  echo "Timezone                          :" ${TIMEZONE}
  echo "Shell user                        :" ${SHELL_USER}
}

function create_root_and_mount_partition() {
  [ ${DEBUG} = "true" ] && echo "debug_info ${LINENO}:IS_MOUNTED=\$(mount|grep ${ROOT_PARTITION})" &>> ${FILE_DEBUG} || \
  IS_MOUNTED=$(mount|grep ${ROOT_PARTITION})
  if [ ! -z "$IS_MOUNTED" ]; then
    echo "La partizione è montata. Esco."
    exit
  fi
  if [ ${YES_NO} = "no" ]; then
    read -p "Attenzione! la partizione ${ROOT_PARTITION} sarà formattata! Continuo?(si/no): " YES_NO
  fi
  if [ -z ${YES_NO} ] || [ ! ${YES_NO} = "si" ]; then
    exit
  fi
  [ ${DEBUG} = "true" ] && echo "debug_info ${LINENO}:mkfs -t ${TYPE_FS} ${ROOT_PARTITION}" &>> ${FILE_DEBUG} || \
  mkfs -t ${TYPE_FS} ${ROOT_PARTITION}
  [ ${DEBUG} = "true" ] && echo "debug_info ${LINENO}:UUID_ROOT_PARTITION=\$(blkid -o value -s UUID ${ROOT_PARTITION})" &>> ${FILE_DEBUG} || \
  UUID_ROOT_PARTITION=$(blkid -o value -s UUID ${ROOT_PARTITION})
  [ ${DEBUG} = "true" ] && echo "debug_info ${LINENO}:mkdir -p ${INST_ROOT_DIRECTORY}" &>> ${FILE_DEBUG} || \
  mkdir -p ${INST_ROOT_DIRECTORY}
  [ ${DEBUG} = "true" ] && echo "debug_info ${LINENO}:mount ${ROOT_PARTITION} ${INST_ROOT_DIRECTORY}" &>> ${FILE_DEBUG} || \
  mount ${ROOT_PARTITION} ${INST_ROOT_DIRECTORY}
}

function create_home_and_mount_partition() {
  [ ${DEBUG} = "true" ] && echo "debug_info ${LINENO}:IS_MOUNTED=\$(mount|grep ${HOME_PARTITION})" &>> ${FILE_DEBUG} || \
  IS_MOUNTED=$(mount|grep ${HOME_PARTITION})
  if [ ! -z "$IS_MOUNTED" ]; then
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
      [ ${DEBUG} = "true" ] && echo "debug_info ${LINENO}:mkfs -t ${TYPE_FS} ${HOME_PARTITION}" &>> ${FILE_DEBUG} || \
      mkfs -t ${TYPE_FS} ${HOME_PARTITION}
    fi
    [ ${DEBUG} = "true" ] && echo "debug_info ${LINENO}:UUID_HOME_PARTITION=\$(blkid -o value -s UUID ${HOME_PARTITION})" &>> ${FILE_DEBUG} || \
    UUID_HOME_PARTITION=$(blkid -o value -s UUID ${HOME_PARTITION})
    [ ${DEBUG} = "true" ] && echo "debug_info ${LINENO}:mkdir -p ${INST_ROOT_DIRECTORY}/home" &>> ${FILE_DEBUG} || \
    mkdir -p ${INST_ROOT_DIRECTORY}/home
    [ ${DEBUG} = "true" ] && echo "debug_info ${LINENO}:mount ${HOME_PARTITION} ${INST_ROOT_DIRECTORY}/home" &>> ${FILE_DEBUG} || \
    mount ${HOME_PARTITION} ${INST_ROOT_DIRECTORY}/home
  fi
}

function copy_root() {
  SQUASH_FS="/lib/live/mount/rootfs/filesystem.squashfs"
  [ ${DEBUG} = "true" ] && echo "debug_info ${LINENO}:cp -av ${SQUASH_FS}/* ${INST_ROOT_DIRECTORY}" &>> ${FILE_DEBUG} || \
  cp -av ${SQUASH_FS}/* ${INST_ROOT_DIRECTORY}
}

function add_user() {
  if [ -z ${USER} ]; then
    read -p "Digita la username: " USER
    if [ -z ${USER} ]; then
      read -p "Bisogna digitare un nome. Prova ancora o premi 'enter': " USER
      [ -z ${USER} ] && echo "Installazione abortita!" && exit -1
    fi
  fi
  if [ -z ${CRYPT_PASSWORD} ]; then
    read -s -p "Digita la password: " USER_PASSWORD
    echo
    if [ -z ${USER_PASSWORD} ]; then
      read -s -p "Password obbligatoria. Prova ancora o premi 'enter': " USER_PASSWORD
      echo
      [ -z ${USER_PASSWORD} ] && echo "Installazione abortita!" && exit -1
    fi
    CRYPT_PASSWORD=$(perl -e 'print crypt($ARGV[0], "password")' ${USER_PASSWORD})
  fi
  [ ${DEBUG} = "true" ] && echo "debug_info ${LINENO}:chroot ${INST_ROOT_DIRECTORY} useradd -G ${ADD_GROUPS} -s ${SHELL_USER} -m -p $CRYPT_PASSWORD $USER" &>> ${FILE_DEBUG} || \
  chroot ${INST_ROOT_DIRECTORY} useradd -G ${ADD_GROUPS} -s ${SHELL_USER} -m -p $CRYPT_PASSWORD $USER
  if [ $? -eq 0 ]; then echo "User has been added to system!" 
  else
    echo "Failed to add a user!";
    exit
  fi
}

function add_sudo_user() {
  [ ${DEBUG} = "true" ] && echo "debug_info ${LINENO}:chroot ${INST_ROOT_DIRECTORY} gpasswd -a ${USER} sudo" &>> ${FILE_DEBUG} || \
  chroot ${INST_ROOT_DIRECTORY} gpasswd -a ${USER} sudo
}

function change_root_password() {
  if [ -z ${CRYPT_ROOT_PASSWORD} ]; then
    read -s -p "Digita la password per l'amministratore root: " ROOT_PASSWORD
    echo
    if [ -z ${ROOT_PASSWORD} ]; then
      read -s -p "Password obbligatoria. Prova ancora o premi 'enter': " ROOT_PASSWORD
      echo
      [ -z ${ROOT_PASSWORD} ] && echo "Installazione abortita!" && exit -1
    fi
    CRYPT_ROOT_PASSWORD=$(perl -e 'print crypt($ARGV[0], "password")' ${ROOT_PASSWORD})
  fi
  [ ${DEBUG} = "true" ] && echo "debug_info ${LINENO}:chroot ${INST_ROOT_DIRECTORY} bash -c \"echo root:${CRYPT_ROOT_PASSWORD} | chpasswd -e\"" &>> ${FILE_DEBUG} || \
  chroot ${INST_ROOT_DIRECTORY} bash -c "echo root:${CRYPT_ROOT_PASSWORD} | chpasswd -e"
}

function create_fstab() {
  [ ${DEBUG} = "true" ] && echo "debug_info ${LINENO}:cat > ${INST_ROOT_DIRECTORY}/etc/fstab" &>> ${FILE_DEBUG} || \
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
  [ ${DEBUG} = "true" ] && echo "debug_info ${LINENO}:cat >> ${INST_ROOT_DIRECTORY}/etc/fstab" &>> ${FILE_DEBUG} || \
    cat >> ${INST_ROOT_DIRECTORY}/etc/fstab <<EOF
UUID=${UUID_HOME_PARTITION} /home ${TYPE_FS} defaults 0 2
EOF
  fi
  if [ ! -z ${SWAP_PARTITION} ]; then
    [ ${DEBUG} = "true" ] && echo "debug_info ${LINENO}:UUID_SWAP_PARTITION=\$(blkid -o value -s UUID ${SWAP_PARTITION})" &>> ${FILE_DEBUG} || \
    UUID_SWAP_PARTITION=$(blkid -o value -s UUID ${SWAP_PARTITION})
    [ ${DEBUG} = "true" ] && echo "debug_info ${LINENO}:cat >> ${INST_ROOT_DIRECTORY}/etc/fstab" &>> ${FILE_DEBUG} || \
    cat >> ${INST_ROOT_DIRECTORY}/etc/fstab <<EOF
UUID=${UUID_SWAP_PARTITION} none swap sw 0 0
EOF
  fi
}

function set_locale() {
  [ ${DEBUG} = "true" ] && echo "debug_info ${LINENO}:LINE=\$(cat ${INST_ROOT_DIRECTORY}/etc/locale.gen|grep \"${LOCALE}\")" &>> ${FILE_DEBUG} || \
  LINE=$(cat ${INST_ROOT_DIRECTORY}/etc/locale.gen|grep "${LOCALE}")
  [ ${DEBUG} = "true" ] && echo "debug_info ${LINENO}:sed -i \"s/${LINE}/${LOCALE}/\" ${INST_ROOT_DIRECTORY}/etc/locale.gen" &>> ${FILE_DEBUG} || \
  sed -i "s/${LINE}/${LOCALE}/" ${INST_ROOT_DIRECTORY}/etc/locale.gen
  [ ${DEBUG} = "true" ] && echo "debug_info ${LINENO}:chroot ${INST_ROOT_DIRECTORY} locale-gen" &>> ${FILE_DEBUG} || \
  chroot ${INST_ROOT_DIRECTORY} locale-gen
  [ ${DEBUG} = "true" ] && echo "debug_info ${LINENO}:chroot ${INST_ROOT_DIRECTORY} update-locale LANG=${LANG}" &>> ${FILE_DEBUG} || \
  chroot ${INST_ROOT_DIRECTORY} update-locale LANG=${LANG}
  [ ${DEBUG} = "true" ] && echo "debug_info ${LINENO}:LINE=\$(cat ${INST_ROOT_DIRECTORY}/etc/default/keyboard|grep \"XKBLAYOUT\")" &>> ${FILE_DEBUG} || \
  LINE=$(cat ${INST_ROOT_DIRECTORY}/etc/default/keyboard|grep "XKBLAYOUT")
  [ ${DEBUG} = "true" ] && echo "debug_info ${LINENO}:sed -i \"s/${LINE}/XKBLAYOUT=\"${KEYBOARD}\\\"/\" ${INST_ROOT_DIRECTORY}/etc/default/keyboard" &>> ${FILE_DEBUG} || \
  sed -i "s/${LINE}/XKBLAYOUT=\"${KEYBOARD}\"/" ${INST_ROOT_DIRECTORY}/etc/default/keyboard
}

function set_timezone() {
  [ ${DEBUG} = "true" ] && echo "debug_info ${LINENO}:cat > ${INST_ROOT_DIRECTORY}/etc/timezone" &>> ${FILE_DEBUG} || \
  cat > ${INST_ROOT_DIRECTORY}/etc/timezone <<EOF
${TIMEZONE}
EOF
}

function set_hostname() {
  [ ${DEBUG} = "true" ] && echo "debug_info ${LINENO}:cat > ${INST_ROOT_DIRECTORY}/etc/hostname" &>> ${FILE_DEBUG} || \
  cat > ${INST_ROOT_DIRECTORY}/etc/hostname <<EOF
${HOSTNAME}
EOF
  [ ${DEBUG} = "true" ] && echo "debug_info ${LINENO}:cat > ${INST_ROOT_DIRECTORY}/etc/hosts" &>> ${FILE_DEBUG} || \
  cat > ${INST_ROOT_DIRECTORY}/etc/hosts <<EOF
127.0.0.1       localhost ${HOSTNAME}
::1             localhost ip6-localhost ip6-loopback
fe00::0         ip6-localnet
ff00::0         ip6-mcastprefix
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
EOF
}

function update_minidlna() {
  [ ${DEBUG} = "true" ] && echo "debug_info ${LINENO}:sed -i \"s/live-user/${USER}/\" ${INST_ROOT_DIRECTORY}/etc/minidlna.conf" &>> ${FILE_DEBUG} || \
  sed -i "s/live-user/${USER}/" ${INST_ROOT_DIRECTORY}/etc/minidlna.conf
}

function install_grub() {
  for dir in dev proc sys; do
    [ ${DEBUG} = "true" ] && echo "debug_info ${LINENO}:mount -B /${dir} ${INST_ROOT_DIRECTORY}/${dir}" &>> ${FILE_DEBUG} || \
    mount -B /${dir} ${INST_ROOT_DIRECTORY}/${dir}
  done
  [ ${DEBUG} = "true" ] && echo "debug_info ${LINENO}:chroot ${INST_ROOT_DIRECTORY} grub-install --no-floppy ${INST_DRIVE}" &>> ${FILE_DEBUG} || \
  chroot ${INST_ROOT_DIRECTORY} grub-install --no-floppy ${INST_DRIVE}
  [ ${DEBUG} = "true" ] && echo "debug_info ${LINENO}:chroot ${INST_ROOT_DIRECTORY} update-grub" &>> ${FILE_DEBUG} || \
  chroot ${INST_ROOT_DIRECTORY} update-grub
  for dir in dev proc sys; do
    [ ${DEBUG} = "true" ] && echo "debug_info ${LINENO}:umount ${INST_ROOT_DIRECTORY}/${dir}" &>> ${FILE_DEBUG} || \
    umount ${INST_ROOT_DIRECTORY}/${dir}
  done
}

function end() {
  [ ${DEBUG} = "true" ] && echo "debug_info ${LINENO}:sync" &>> ${FILE_DEBUG} || \
  sync
  [ ${DEBUG} = "true" ] && echo "debug_info ${LINENO}:umount ${HOME_PARTITION}" &>> ${FILE_DEBUG} || \
  umount ${HOME_PARTITION}
  [ ${DEBUG} = "true" ] && echo "debug_info ${LINENO}:umount ${ROOT_PARTITION}" &>> ${FILE_DEBUG} || \
  umount ${ROOT_PARTITION}
  [ ${DEBUG} = "true" ] && echo -e "-----------------------------------------------------------------------\ndebug_info ${LINENO}:Debug terminato:$(date)\n-----------------------------------------------------------------------" &>> ${FILE_DEBUG} || \
  echo "Installazione terminata."
}

function run_inst {
  check_debug
  check_root
  check_script
  put_info
  create_root_and_mount_partition
  create_home_and_mount_partition
  copy_root
  add_user
  change_root_password
  add_sudo_user
  create_fstab
  set_locale
  set_timezone
  set_hostname
  update_minidlna
  install_grub
  end
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
    -D | --debug)
      shift
      DEBUG="true"
      ;;
    -f | --format-home)
      shift
      FORMAT_HOME="si"
      ;;
    -F | --file-debug)
      shift
      FILE_DEBUG=${1}
      ;;
    -g | --groups)
      shift
      ADD_GROUPS=$1
      ;;
    -h | --help)
      shift
      help
      exit
      ;;
    -H | --home-partition)
      shift
      HOME_PARTITION=${1}
      ;;
    -i | --inst-root-directory)
      shift
      INST_ROOT_DIRECTORY=${1}
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
    -r | --root-partition)
      shift
      ROOT_PARTITION=${1}
      ;;
    -s | --swap-partition)
      shift
      SWAP_PARTITION=${1}
      ;;
    -S | --shell-user)
      shift
      SHELL_USER=${1}
      ;;
    -t | --type-fs)
      shift
      TYPE_FS=${1}
      ;;
    -T | --timezone)
      shift
      TIMEZONE=${1}
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

run_inst
