#!/bin/bash
#
#---------------------------VARS----------------------------------------
ROOT_PARTITION="sda1"
USE_HOME="FALSE"
HOME_PARTITION=
SWAP_PARTITION=
FORMAT_HOME="FALSE"
DEBUG="FALSE"
YES_NO="FALSE"
FILE_DEBUG="./debug.txt"
DISTRO="distro"
INST_DRIVE="sda"
LOCALE="it_IT.UTF-8 UTF-8"
LANGUAGE_CODE="it_IT.UTF-8"
KEYBOARD="it"
HOSTNAME="debian"
ADD_GROUPS="cdrom,floppy,audio,dip,video,plugdev,fuse,scanner,bluetooth,netdev,android"
TIMEZONE="Europe/Rome"
SHELL_USER="/bin/bash"
INST_ROOT_DIRECTORY="/mnt/${DISTRO}"
TYPE_FS="ext4"
USER=
USER_PASSWORD=
CRYPT_PASSWORD=
CRYPT_ROOT_PASSWORD=
MESSAGE="C'è stato un problema... Esco. "

#-----------------------------------------------------------------------
PARTITIONS="$(awk '{if ($4 ~ /[hs]d[a-z][1-9]/) print $4}' /proc/partitions)"
PART_ARRAY=($PARTITIONS)
length=$((${#PART_ARRAY[@]} - 1))
for (( i=0; i <= length; i++ )); do
  strtmp=${PART_ARRAY[$i]}
  [[ ${strtmp} = ${ROOT_PARTITION} ]] && partitionslist+="^"
  [[ $i -lt $length ]] && partitionslist+="${strtmp}"! || partitionslist+="${strtmp}";
done
DISKS="$(awk '{if (length($4)==3 && $4 ~ /[hs]d/) print $4}' /proc/partitions)"
DISKS_ARRAY=($DISKS)
length=$((${#DISKS_ARRAY[@]} - 1))
for (( i=0; i <= length; i++ )); do
  [[ $i -lt $length ]] && diskslist+="${DISKS_ARRAY[$i]}"! || diskslist+="${DISKS_ARRAY[$i]}"
done
#------------------------------functions--------------------------------
function error_exit() {
  yad --center --button=gtk-close --buttons-layout=center --image=gtk-dialog-error --text="$MESSAGE"
  exit
}

function parse_opts() {
  # Note the quotes around `$TEMP': they are essential!
  eval set -- "$TEMP"
  while true ; do
  case "$1" in
    -c|--crypt-password) CRYPT_PASSWORD=$2;echo $CRYPT_PASSWORD;shift 2;;
    -C|--crypt-root-password) CRYPT_ROOT_PASSWORD=$2;echo $CRYPT_ROOT_PASSWORD;shift 2;;
    -d|--inst-drive) INST_DRIVE=$2;echo $INST_DRIVE;shift 2;;
    -D|--debug) DEBUG="TRUE";echo $DEBUG;shift;;
    -f|--format) FORMAT_HOME="TRUE";echo $FORMAT_HOME;shift;;
    -F|--file-debug) FILE_DEBUG=$2;echo $FILE_DEBUG;shift 2;;
    -g|--groups) ADD_GROUPS=${2//' '/}; echo $ADD_GROUPS;shift 2;;
    -h|--help) exit;shift;;
    -H|--home-partition) HOME_PARTITION=$2;USE_HOME="TRUE";echo $HOME_PARTITION;echo $USE_HOME;shift 2;;
    -i|--inst-root-directory) INST_ROOT_DIRECTORY=$2;echo $INST_ROOT_DIRECTORY;shift 2;;
    -k|--keyboard) KEYBOARD=$2;echo $KEYBOARD;shift 2;;
    -l|--locale) LOCALE=$2;echo $LOCALE;shift 2;;
    -L|--language) LANGUAGE_CODE=$2;echo $LANGUAGE_CODE;shift 2;;
    -n|--hostname) HOSTNAME=$2;echo $HOSTNAME;shift 2;;
    -r|--root-partition) ROOT_PARTITION=$2;echo $ROOT_PARTITION;shift 2;;
    -s|--swap-partition) SWAP_PARTITION=$2;echo $SWAP_PARTITION;shift 2;;
    -S|--shell-user) SHELL_USER=$2;echo $SHELL_USER;shift 2;;
    -t|--type-fs) TYPE_FS=$2;echo $TYPE_FS;shift 2;;
    -T|--timezone) TIMEZONE=$2;echo $TIMEZONE;shift 2;;
    -u|--user) USER=$2;echo $USER ;shift 2;;
    -y|--yes) YES_NO="TRUE";echo $YES_NO;shift;;
		--) shift ; break ;;
		*) echo "Internal error!" ; exit 1 ;;
	esac
done
}

function set_options() {
  result=$(yad --center --form --image "dialog-question" --separator='\n' --quoted-output --title="Opzioni" --text="Opzioni modificabili. Il nome  utente e la password sono obbligatori" \
  --field="Nome distro:" "$DISTRO" \
  --field="Partizione di root:cb" "$partitionslist" \
  --field="Drive di installazione::cb" "$diskslist" \
  --field="Locale:" "$LOCALE" \
  --field="Lingua:" "$LANGUAGE_CODE" \
  --field="Tastiera:" "$KEYBOARD" \
  --field="Hostname:" "$HOSTNAME" \
  --field="Gruppi utente:" "$ADD_GROUPS" \
  --field="Shell utente:" "$SHELL_USER" \
  --field="Partizione di home:chk" "$USE_HOME" \
  --field="Debuggare:chk" "$DEBUG"
  )
  array_result=($result)
  if [[ $result ]]; then
    DISTRO="${array_result[0]//\'/}";echo $DISTRO
    ROOT_PARTITION=${array_result[1]//\'/};echo $ROOT_PARTITION
    INST_DRIVE=${array_result[2]//\'/};echo $INST_DRIVE
    LOCALE="${array_result[3]//\'/} ${array_result[4]//\'/}"; echo $LOCALE
    LANGUAGE_CODE=${array_result[5]//\'/}; echo $LANGUAGE_CODE
    KEYBOARD=${array_result[6]//\'/}; echo $KEYBOARD
    HOSTNAME=${array_result[7]//\'/}; echo $HOSTNAME
    ADD_GROUPS=${array_result[8]//\'/}; echo $ADD_GROUPS
    SHELL_USER=${array_result[9]//\'/}; echo $SHELL_USER
    USE_HOME=${array_result[10]//\'/}; echo $USE_HOME
    DEBUG=${array_result[11]//\'/}; echo $DEBUG
  else
    error_exit
  fi
}

function check_options() {
  
  if [ ${YES_NO} = "si" ] && [ -z ${USER} ]; then
    MESSAGE="Con l'opzione -y deve essere specificato lo user, la password cryptata dello user e la password cryptata di root."
    error_exit
  fi
  if [ ${YES_NO} = "si" ] && [ -z ${CRYPT_PASSWORD} ]; then
    MESSAGE="Con l'opzione -y deve essere specificato lo user, la password cryptata dello user e la password cryptata di root."
    error_exit
  fi
  if [ ${YES_NO} = "si" ] && [ -z ${CRYPT_ROOT_PASSWORD} ]; then
    MESSAGE="Con l'opzione -y deve essere specificato lo user, la password cryptata dello user e la password cryptata di root."
    error_exit
  fi
  [ $YES_NO = "FALSE" ] && yad --center --button=gtk-close --image=gtk-dialog-info --text="Script verificato. OK."
}

function set_home_partition() {
  if [ $USE_HOME="TRUE" ]; then
    list=$(echo ${partitionslist//$ROOT_PARTITION!/})
    res=$(yad --center --form --image "dialog-question" --separator='\n' \
      --field="Partizione home:cb" "$list" \
      --field="Formattare lapartizione:chk" $FORMAT_HOME
    )
    arr=($res)
    HOME_PARTITION=${res[0]}
    FORMAT_HOME=${res[1]}
  fi
}

function set_user() {
  res=$(yad --center --form --image="dialog-question" --separator='\n' \
    --field="Nome utente:" $USER \
    --field="Password:h"
  )
  array=($res)
  [ ${array[0]} ] && USER=${array[0]} || error_exit
  [ ${array[1]} ] && USER_PASSWORD=${array[1]} || error_exit
  CRYPT_PASSWORD=$(perl -e 'print crypt($ARGV[0], "password")' ${USER_PASSWORD})
}

function set_root_password() {
  res=$(yad --center --form --image="dialog-question" --separator='\n' --field="Passord di root:h")
  [ $res ] && CRYPT_ROOT_PASSWORD=$(perl -e 'print crypt($ARGV[0], "password")' ${res}) || error_exit
}

function run_inst(){
  parse_opts
  [ $YES_NO = "FALSE" ] && set_options
  check_options
  [ $USE_HOME = "TRUE" ] && [ -z $HOME_PARTITION ] && set_home_partition
  [ -z $USER ] && set_user
  [ -z $CRYPT_PASSWORD ] && set_user
  [ -z $CRYPT_ROOT_PASSWORD ] && set_root_password
}
#---------------------------MAIN----------------------------------------
TEMP=$(getopt -o c:C:d:DfF:g:hH:i:k:l:L:n:r:s:S:t:T:u:y --long crypt-password:,crypt-root-password:,inst-drive:,debug,format-home,file-debug:,groups:,help,home-partition:,inst-root-directory:,keyboard:,locale:,language:,hostname:,root-partition:,swap-partition:,shell-user:,type-fs:,timezone:,user:,yes -n 'yad_install_distro.sh' -- "$@")
if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi
run_inst
echo $USER
echo $CRYPT_PASSWORD
echo $CRYPT_ROOT_PASSWORD
echo $HOME_PARTITION
echo $USE_HOME
