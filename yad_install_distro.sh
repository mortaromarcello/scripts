#!/bin/bash

#-----------------------------------------------------------------------
# FUNZIONI
#-----------------------------------------------------------------------
function get_partitions_and_disks() {
    PARTITIONS="$(awk '{if ($4 ~ /[hs]d[a-z][1-9]/) print $4}' /proc/partitions)"
    EXTENDED_PARTITIONS="$(fdisk -l | awk '{if ($0 ~ / 5 /) print $1}')"
    PART_ARRAY=($PARTITIONS)
    PART_ARRAY=($(IFS=$'\n' sort <<< "${PART_ARRAY[*]}"))
    EXT_ARRAY=($EXTENDED_PARTITIONS)
    length=$((${#PART_ARRAY[@]} - 1))
    lenght2=$((${#EXT_ARRAY[@]} -1))
    for (( i=0; i <= length; i++ )); do
        strtmp=${PART_ARRAY[$i]}
        for (( l=0; l <= lenght2; l++ )); do
            CHECK_EXT="false"
            if [ "/dev/"${strtmp} = ${EXT_ARRAY[$l]} ]; then
                CHECK_EXT="true"
                echo $CHECK_EXT
                break
            fi
        done
        if [ ${CHECK_EXT} = "false" ]; then
            [[ ${strtmp} = ${ROOT_PARTITION} ]] && partitionslist+="^"
            [[ $i -lt $length ]] && partitionslist+="${strtmp}"! || partitionslist+="${strtmp}";
        fi
    done
    DISKS="$(awk '{if (length($4)==3 && $4 ~ /[hs]d/) print $4}' /proc/partitions)"
    DISKS_ARRAY=($DISKS)
    DISKS_ARRAY=($(IFS=$'\n' sort <<< "${DISKS_ARRAY[*]}"))
    length=$((${#DISKS_ARRAY[@]} - 1))
    for (( i=0; i <= length; i++ )); do
        [[ $i -lt $length ]] && diskslist+="${DISKS_ARRAY[$i]}"! || diskslist+="${DISKS_ARRAY[$i]}"
    done
}

function init() {
    ROOT_PARTITION="sda1"
    USE_HOME="FALSE"
    HOME_PARTITION=
    SWAP_PARTITION=
    FORMAT_HOME="FALSE"
    DEBUG="FALSE"
    YES_NO="FALSE"
    FILE_DEBUG="./debug.txt"
    FILE_LOG="./log.txt"
    DISTRO="distro"
    INST_DRIVE="sda"
    LOCALE="it_IT.UTF-8 UTF-8"
    LANGUAGE_CODE="it_IT.UTF-8"
    KEYBOARD="it"
    HOSTNAME="debian"
    SLIM="/usr/bin/slim"
    SDDM="/usr/bin/sddm"
    LIGHTDM="/usr/sbin/lightdm"
    AUTOLOGIN="TRUE"
    ADD_GROUPS="cdrom,floppy,audio,dip,video,plugdev,lp,dialout,netdev"
    TIMEZONE="Europe/Rome"
    SHELL_USER="/bin/bash"
    INST_ROOT_DIRECTORY="/mnt/${DISTRO}"
    TYPE_FS="ext4"
    USER=
    USER_PASSWORD=
    CRYPT_PASSWORD=
    CRYPT_ROOT_PASSWORD=
    MESSAGE=" C'è stato un problema... Esco. "
    PROC_ID=
}

function error_exit() {
    echo ${MESSAGE} >> ${FILE_LOG}
    [[ $PROC_ID ]] && kill -9 ${PROC_ID}
    yad --on-top --center --button=gtk-close --buttons-layout=center --image=gtk-dialog-error --text="\n${MESSAGE}\n"
    exit
}

function check_root() {
    if [ ${UID} != 0 ]; then
    MESSAGE="  Devi essere root per eseguire questo script. "
        error_exit
    fi
}

function parse_opts() {
    # Note the quotes around `$TEMP': they are essential!
    eval set -- "$TEMP"
    while true ; do
        case "$1" in
            -a|--autologin) AUTOLOGIN=$2;echo "$AUTOLOGIN";shift 2;;
            -c|--crypt-password) CRYPT_PASSWORD=$2;echo "$CRYPT_PASSWORD";shift 2;;
            -C|--crypt-root-password) CRYPT_ROOT_PASSWORD=$2;echo "$CRYPT_ROOT_PASSWORD";shift 2;;
            -d|--inst-drive) INST_DRIVE=$2;echo "$INST_DRIVE";shift 2;;
            -D|--debug) DEBUG="TRUE";echo $DEBUG;shift;;
            -f|--format) FORMAT_HOME="TRUE";echo "$FORMAT_HOME";shift;;
            -F|--file-debug) FILE_DEBUG=$2;echo "$FILE_DEBUG";shift 2;;
            -g|--groups) ADD_GROUPS=${2//' '/}; echo "$ADD_GROUPS";shift 2;;
            -h|--help) exit;shift;;
            -H|--home-partition) HOME_PARTITION=$2;USE_HOME="TRUE";echo "$HOME_PARTITION";echo "$USE_HOME";shift 2;;
            -i|--inst-root-directory) INST_ROOT_DIRECTORY=$2;echo "$INST_ROOT_DIRECTORY";shift 2;;
            -k|--keyboard) KEYBOARD=$2;echo "$KEYBOARD";shift 2;;
            -l|--locale) LOCALE=$2;echo "$LOCALE";shift 2;;
            -L|--language) LANGUAGE_CODE=$2;echo "$LANGUAGE_CODE";shift 2;;
            -n|--hostname) HOSTNAME=$2;echo "$HOSTNAME";shift 2;;
            -r|--root-partition) ROOT_PARTITION=$2;echo "$ROOT_PARTITION";shift 2;;
            -s|--swap-partition) SWAP_PARTITION=$2;echo "$SWAP_PARTITION";shift 2;;
            -S|--shell-user) SHELL_USER=$2;echo "$SHELL_USER";shift 2;;
            -t|--type-fs) TYPE_FS=$2;echo "$TYPE_FS";shift 2;;
            -T|--timezone) TIMEZONE=$2;echo "$TIMEZONE";shift 2;;
            -u|--user) USER=$2;echo "$USER";shift 2;;
            -y|--yes) YES_NO="TRUE";echo "$YES_NO";shift;;
            --) shift ; break ;;
            *) echo "Internal error!" ; exit 1 ;;
        esac
    done
}

function set_options() {
    result=$(yad --on-top --center --form --image "dialog-question" --separator='\n' --quoted-output --title="Opzioni" --text=" Opzioni modificabili " \
    --field="Nome distro:" "$DISTRO" \
    --field="Partizione di root:cb" "$partitionslist" \
    --field="Drive di installazione::cb" "$diskslist" \
    --field="Locale:" "$LOCALE" \
    --field="Lingua:" "$LANGUAGE_CODE" \
    --field="Tastiera:" "$KEYBOARD" \
    --field="Hostname:" "$HOSTNAME" \
    --field="Gruppi utente:" "$ADD_GROUPS" \
    --field="Shell utente:" "$SHELL_USER" \
    --field="Autologin:chk" "$AUTOLOGIN" \
    --field="Partizione di home:chk" "$USE_HOME" \
    --field="Debuggare:chk" "$DEBUG"
    )
    array_result=($result)
    if [[ $result ]]; then
        DISTRO="${array_result[0]//\'/}";echo "$DISTRO"
        ROOT_PARTITION=${array_result[1]//\'/};echo "$ROOT_PARTITION"
        INST_DRIVE=${array_result[2]//\'/};echo "$INST_DRIVE"
        LOCALE="${array_result[3]//\'/} ${array_result[4]//\'/}"; echo "$LOCALE"
        LANGUAGE_CODE=${array_result[5]//\'/}; echo "$LANGUAGE_CODE"
        KEYBOARD=${array_result[6]//\'/}; echo "$KEYBOARD"
        HOSTNAME=${array_result[7]//\'/}; echo "$HOSTNAME"
        ADD_GROUPS=${array_result[8]//\'/}; echo "$ADD_GROUPS"
        SHELL_USER=${array_result[9]//\'/}; echo "$SHELL_USER"
        AUTOLOGIN=${array_result[10]//\'/}; echo "$AUTOLOGIN"
        USE_HOME=${array_result[11]//\'/}; echo "$USE_HOME"
        DEBUG=${array_result[12]//\'/}; echo "$DEBUG"
    else
        MESSAGE=" C'è stato un problema. Esco. "
        error_exit
    fi
}

function check_debug() {
    if [ "${DEBUG}" = "TRUE" ]; then
        set -x
        echo -e "-----------------------------------------------------------------------\ndebug_info ${LINENO}:Debug iniziato:$(date)\n-----------------------------------------------------------------------" >> "${FILE_DEBUG}"
        echo "debug_info ${LINENO}:Debug abilitato." >> "${FILE_DEBUG}"
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
        AUTOLOGIN=${AUTOLOGIN}
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
        " >> "${FILE_DEBUG}"
    fi
}

function check_options() {
    if [ ${YES_NO} = "TRUE" ] && [ -z "${USER}" ]; then
        MESSAGE=" Con l'opzione -y deve essere specificato lo user, la password cryptata dello user e la password cryptata di root. "
        error_exit
    fi
    if [ ${YES_NO} = "TRUE" ] && [ -z "${CRYPT_PASSWORD}" ]; then
        MESSAGE=" Con l'opzione -y deve essere specificato lo user, la password cryptata dello user e la password cryptata di root. "
        error_exit
    fi
    if [ ${YES_NO} = "TRUE" ] && [ -z "${CRYPT_ROOT_PASSWORD}" ]; then
        MESSAGE=" Con l'opzione -y deve essere specificato lo user, la password cryptata dello user e la password cryptata di root. "
        error_exit
    fi
    #[ ${YES_NO} = "FALSE" ] && yad --center --button=gtk-close --image=gtk-dialog-info --text=" Script verificato. OK. "
}

function set_home_partition() {
    echo -e "#-Imposto la partizione home-#" >> ${FILE_LOG}
    if [ "${USE_HOME}" = "TRUE" ]; then
        list=$(echo ${partitionslist//$ROOT_PARTITION!/})
        res=$(yad --on-top --center --form --image "dialog-question" --separator='\n' \
        --field="Partizione home:cb" "$list" \
        --field="Formattare la partizione:chk" $FORMAT_HOME
        )
        if [[ $res ]]; then
            arr=($res)
            HOME_PARTITION=${arr[0]}
            FORMAT_HOME=${arr[1]}
            echo -e "#-Impostasto la partizione di home a: /dev/${HOME_PARTITION}-#" >> ${FILE_LOG}
        else
            MESSAGE=" C'è stato un errore. Esco. "
            error_exit
        fi
    fi
}

function set_swap_partition() {
    SWAP_PARTITION=$(fdisk -l|awk '{if ($0 ~ /[Ss]wap/) print $1}')
    echo -e "#-Trovata partizione di swap ${SWAP_PARTITION}.-#" >> ${FILE_LOG}
}

function set_user() {
    echo -e "#-Imposto l'utente di default-#"
    res=$(yad --on-top --center --form --image="dialog-question" --separator='\n' \
        --field="Nome utente:" $USER \
        --field="Password:h"
    )
    array=($res)
    if [ ${array[0]} ]; then 
        USER=${array[0]}
    else
        MESSAGE=" Bisogna inserire un nome utente. Esco. "
        error_exit
    fi
    if [ ${array[1]} ]; then
        USER_PASSWORD=${array[1]}
    else
        MESSAGE=" Bisogna inserire la password. Esco. "
        error_exit
    fi
    CRYPT_PASSWORD=$(perl -e 'print crypt($ARGV[0], "password")' ${USER_PASSWORD})
    echo -e "#-Utente ${USER}, password criptata ${CRYPT_PASSWORD}-#" >> ${FILE_LOG}
}

function set_root_password() {
    echo -e "#-Imposto la password di root-#"
    res=$(yad --on-top --center --form --image="dialog-question" --separator='\n' --field="Passord di root:h")
    if [ $res ]; then
        CRYPT_ROOT_PASSWORD=$(perl -e 'print crypt($ARGV[0], "password")' ${res})
    else
        MESSAGE=" Bisogna inserire una password! Esco. "
        error_exit
    fi
    echo -e "#-Password criptata di root ${CRYPT_ROOT_PASSWORD}-#" >> ${FILE_LOG}
}

function create_root_and_mount_partition() {
    echo -e "#-Imposto la partizione di root a ${ROOT_PARTITION}-#" >> ${FILE_LOG}
    [ ${DEBUG} = "TRUE" ] && echo "debug_info ${LINENO}:IS_MOUNTED=\$(mount|grep /dev/${ROOT_PARTITION})" &>> ${FILE_DEBUG} || \
    IS_MOUNTED=$(mount|grep /dev/${ROOT_PARTITION})
    if [ ! -z "$IS_MOUNTED" ]; then
        MESSAGE=" La partizione è montata. Esco. "
        error_exit
    fi
    if [ ${YES_NO} = "FALSE" ]; then
        ret=$(yad --on-top --title="Attenzione!!!" \
        --image=gtk-dialog-warning --text="Attenzione! La partizione /dev/${ROOT_PARTITION} sarà formattata! Continuo?" \
        --button="gtk-ok:0" --button="gtk-close:1")
        [[ $ret -eq 1 ]] && MESSAGE=" Installazione interrotta " && error_exit
    fi
    [ ${DEBUG} = "TRUE" ] && echo "debug_info ${LINENO}:mkfs -t ${TYPE_FS} /dev/${ROOT_PARTITION}" &>> ${FILE_DEBUG} || \
    mkfs -F -t ${TYPE_FS} /dev/${ROOT_PARTITION}
    echo -e "#-Formattata la partizione /dev/${ROOT_PARTITION}.-#" >> ${FILE_LOG}
    [ ${DEBUG} = "TRUE" ] && echo "debug_info ${LINENO}:UUID_ROOT_PARTITION=\$(blkid -o value -s UUID /dev/${ROOT_PARTITION})" &>> ${FILE_DEBUG} || \
    UUID_ROOT_PARTITION=$(blkid -o value -s UUID /dev/${ROOT_PARTITION})
    [ ${DEBUG} = "TRUE" ] && echo "debug_info ${LINENO}:mkdir -p ${INST_ROOT_DIRECTORY}" &>> ${FILE_DEBUG} || \
    mkdir -p ${INST_ROOT_DIRECTORY}
    [ ${DEBUG} = "TRUE" ] && echo "debug_info ${LINENO}:mount /dev/${ROOT_PARTITION} ${INST_ROOT_DIRECTORY}" &>> ${FILE_DEBUG} || \
    mount /dev/${ROOT_PARTITION} ${INST_ROOT_DIRECTORY}
    echo -e "#-Montaggio di /dev/${ROOT_PARTITION} in ${INST_ROOT_DIRECTORY}-#" >> ${FILE_LOG}
}

function create_home_and_mount_partition() {
    [ ${DEBUG} = "TRUE" ] && echo "debug_info ${LINENO}:IS_MOUNTED=\$(mount|grep /dev/${HOME_PARTITION})" &>> ${FILE_DEBUG} || \
    IS_MOUNTED=$(mount|grep /dev/${HOME_PARTITION})
    if [ ! -z "$IS_MOUNTED" ]; then
        MESSAGE=" La partizione è montata. Esco. "
        error_exit
    fi
    if [ ! -z ${HOME_PARTITION} ]; then
        if [ ${FORMAT_HOME} = "TRUE" ]; then
            if [ ${YES_NO} = "FALSE" ]; then
                ret=$(yad --on-top --title="Attenzione!!!" \
                --image=gtk-dialog-warning --text="Attenzione! La partizione /dev/${HOME_PARTITION} sarà formattata! Continuo?" \
                --button="gtk-ok:0" --button="gtk-close:1")
                [[ $ret -eq 1 ]] && MESSAGE=" Installazione interrotta " && error_exit
            fi
            [ ${DEBUG} = "TRUE" ] && echo "debug_info ${LINENO}:mkfs -t ${TYPE_FS} /dev/${HOME_PARTITION}" &>> ${FILE_DEBUG} || \
            mkfs -F -t ${TYPE_FS} /dev/${HOME_PARTITION}
            echo -e "#-Formattata la partizione /dev/${HOME_PARTITION}-#" >> ${FILE_LOG}
        fi
        [ ${DEBUG} = "TRUE" ] && echo "debug_info ${LINENO}:UUID_HOME_PARTITION=\$(blkid -o value -s UUID /dev/${HOME_PARTITION})" &>> ${FILE_DEBUG} || \
        UUID_HOME_PARTITION=$(blkid -o value -s UUID /dev/${HOME_PARTITION})
        [ ${DEBUG} = "TRUE" ] && echo "debug_info ${LINENO}:mkdir -p ${INST_ROOT_DIRECTORY}/home" &>> ${FILE_DEBUG} || \
        mkdir -p ${INST_ROOT_DIRECTORY}/home
        [ ${DEBUG} = "TRUE" ] && echo "debug_info ${LINENO}:mount /dev/${HOME_PARTITION} ${INST_ROOT_DIRECTORY}/home" &>> ${FILE_DEBUG} || \
        mount /dev/${HOME_PARTITION} ${INST_ROOT_DIRECTORY}/home
        echo -e "#-Montaggio di /dev/${HOME_PARTITION} in ${INST_ROOT_DIRECTORY}/home-#" >> ${FILE_LOG}
    fi
}

function copy_root() {
    SQUASH_FS="/lib/live/mount/rootfs/filesystem.squashfs"
    echo -e "#-Inizio copia del root system-#" >> ${FILE_LOG}
    [ ${DEBUG} = "TRUE" ] && echo "debug_info ${LINENO}:yad --progress --auto-close --pulsate | cp -av ${SQUASH_FS}/* ${INST_ROOT_DIRECTORY}" &>> ${FILE_DEBUG} || \
    rsync -av ${SQUASH_FS}/* ${INST_ROOT_DIRECTORY} >> ${FILE_LOG}
    echo -e "#-Fine copia del root system-#" >> ${FILE_LOG}
}

function add_user() {
    echo -e "#-Aggiungo user ${USER}-#" >> ${FILE_LOG}
    [ ${DEBUG} = "TRUE" ] && echo "debug_info ${LINENO}:chroot ${INST_ROOT_DIRECTORY} useradd -G ${ADD_GROUPS} -s ${SHELL_USER} -m -p $CRYPT_PASSWORD $USER" &>> ${FILE_DEBUG} || \
    chroot ${INST_ROOT_DIRECTORY} useradd -G ${ADD_GROUPS} -s ${SHELL_USER} -m -p $CRYPT_PASSWORD $USER
    if [ $? -eq 0 ]; then echo "User ${USER} has been added to system!">>${FILE_LOG}
    else
        MESSAGE=" Failed to add a user! "
        error_exit
    fi
    echo -e "#-Aggiunto user ${USER}-#"
}

function add_sudo_user() {
    echo -e "#-Aggiungo ${USER} al gruppo sudo-#" >> ${FILE_LOG}
    [ ${DEBUG} = "TRUE" ] && echo "debug_info ${LINENO}:chroot ${INST_ROOT_DIRECTORY} gpasswd -a ${USER} sudo" &>> ${FILE_DEBUG} || \
    chroot ${INST_ROOT_DIRECTORY} gpasswd -a ${USER} sudo
    echo -e "#-Aggiunto user ${USER} al gruppo 'sudo'.-#">>${FILE_LOG}
}

function create_fstab() {
    echo -e "#-Aggiorno fstab-#" >> ${FILE_LOG}
    [ ${DEBUG} = "TRUE" ] && echo "debug_info ${LINENO}:cat > ${INST_ROOT_DIRECTORY}/etc/fstab" &>> ${FILE_DEBUG} || \
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
        [ ${DEBUG} = "TRUE" ] && echo "debug_info ${LINENO}:cat >> ${INST_ROOT_DIRECTORY}/etc/fstab" &>> ${FILE_DEBUG} || \
        cat >> ${INST_ROOT_DIRECTORY}/etc/fstab <<EOF
UUID=${UUID_HOME_PARTITION} /home ${TYPE_FS} defaults 0 2
EOF
    fi
    if [ ! -z ${SWAP_PARTITION} ]; then
        [ ${DEBUG} = "TRUE" ] && echo "debug_info ${LINENO}:UUID_SWAP_PARTITION=\$(blkid -o value -s UUID ${SWAP_PARTITION})" &>> ${FILE_DEBUG} || \
        UUID_SWAP_PARTITION=$(blkid -o value -s UUID ${SWAP_PARTITION})
        [ ${DEBUG} = "TRUE" ] && echo "debug_info ${LINENO}:cat >> ${INST_ROOT_DIRECTORY}/etc/fstab" &>> ${FILE_DEBUG} || \
        cat >> ${INST_ROOT_DIRECTORY}/etc/fstab <<EOF
UUID=${UUID_SWAP_PARTITION} none swap sw 0 0
EOF
    fi
    echo -e "#-Aggiornato /etc/fstab.-#">>${FILE_LOG}
}

function set_locale() {
    echo -e "#-Setto locale a ${LOCALE}-#" >> ${FILE_LOG}
    [ ${DEBUG} = "TRUE" ] && echo "debug_info ${LINENO}:LINE=\$(cat ${INST_ROOT_DIRECTORY}/etc/locale.gen|grep \"${LOCALE}\")" &>> ${FILE_DEBUG} || \
    LINE=$(cat ${INST_ROOT_DIRECTORY}/etc/locale.gen|grep "${LOCALE}")
    [ ${DEBUG} = "TRUE" ] && echo "debug_info ${LINENO}:sed -i \"s/${LINE}/${LOCALE}/\" ${INST_ROOT_DIRECTORY}/etc/locale.gen" &>> ${FILE_DEBUG} || \
    sed -i "s/${LINE}/${LOCALE}/" ${INST_ROOT_DIRECTORY}/etc/locale.gen
    [ ${DEBUG} = "TRUE" ] && echo "debug_info ${LINENO}:chroot ${INST_ROOT_DIRECTORY} locale-gen" &>> ${FILE_DEBUG} || \
    chroot ${INST_ROOT_DIRECTORY} locale-gen
    [ ${DEBUG} = "TRUE" ] && echo "debug_info ${LINENO}:chroot ${INST_ROOT_DIRECTORY} update-locale LANG=${LANG}" &>> ${FILE_DEBUG} || \
    chroot ${INST_ROOT_DIRECTORY} update-locale LANG=${LANG}
    [ ${DEBUG} = "TRUE" ] && echo "debug_info ${LINENO}:LINE=\$(cat ${INST_ROOT_DIRECTORY}/etc/default/keyboard|grep \"XKBLAYOUT\")" &>> ${FILE_DEBUG} || \
    LINE=$(cat ${INST_ROOT_DIRECTORY}/etc/default/keyboard|grep "XKBLAYOUT")
    [ ${DEBUG} = "TRUE" ] && echo "debug_info ${LINENO}:sed -i \"s/${LINE}/XKBLAYOUT=\"${KEYBOARD}\\\"/\" ${INST_ROOT_DIRECTORY}/etc/default/keyboard" &>> ${FILE_DEBUG} || \
    sed -i "s/${LINE}/XKBLAYOUT=\"${KEYBOARD}\"/" ${INST_ROOT_DIRECTORY}/etc/default/keyboard
    echo -e "Settato locale a ${LOCALE}, la lingua a ${LANG} e la tastiera a ${KEYBOARD}">>${FILE_LOG}
}

function set_timezone() {
    echo -e "#-Setto timezone a ${TIMEZONE}-#" >> ${FILE_LOG}
    [ ${DEBUG} = "TRUE" ] && echo "debug_info ${LINENO}:cat > ${INST_ROOT_DIRECTORY}/etc/timezone" &>> ${FILE_DEBUG} || \
    cp -v ${INST_ROOT_DIRECTORY}/usr/share/zoneinfo/${TIMEZONE} ${INST_ROOT_DIRECTORY}/etc/timezone
    echo -e "Settato timezona a ${TIMEZONE}">>${FILE_LOG}
}

function set_hostname() {
    echo -e "#-Setto hostname a ${HOSTNAME}-#" >> ${FILE_LOG}
    [ ${DEBUG} = "TRUE" ] && echo "debug_info ${LINENO}:cat > ${INST_ROOT_DIRECTORY}/etc/hostname" &>> ${FILE_DEBUG} || \
    cat > ${INST_ROOT_DIRECTORY}/etc/hostname <<EOF
${HOSTNAME}
EOF
    [ ${DEBUG} = "TRUE" ] && echo "debug_info ${LINENO}:cat > ${INST_ROOT_DIRECTORY}/etc/hosts" &>> ${FILE_DEBUG} || \
    cat > ${INST_ROOT_DIRECTORY}/etc/hosts <<EOF
127.0.0.1       localhost ${HOSTNAME}
::1             localhost ip6-localhost ip6-loopback
fe00::0         ip6-localnet
ff00::0         ip6-mcastprefix
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
EOF
    echo -e "Settato hostname a ${HOSTNAME}.">>${FILE_LOG}
}

function set_autologin() {
    if [ ${AUTOLOGIN} = "TRUE" ]; then
        echo -e "#-Imposto l'autologin per ${USER}-#" >> ${FILE_LOG}
        DM=$(cat "${INST_ROOT_DIRECTORY}"/etc/X11/default-display-manager)
        if [ "${DM}" = "" ]; then
            return
        fi
        echo -e "Imposto l'autologin per il display manager ${DM}" >>${FILE_LOG}
        if [ "${DM}" = "${LIGHTDM}" ]; then
            LINE=$(grep "#autologin-user=" "${INST_ROOT_DIRECTORY}"/etc/lightdm/lightdm.conf)
            rpl "${LINE}" "autologin-user=${USER}" "${INST_ROOT_DIRECTORY}"/etc/lightdm/lightdm.conf
            LINE=$(grep "#autologin-user-timeout=" "${INST_ROOT_DIRECTORY}"/etc/lightdm/lightdm.conf)
            rpl "${LINE}" "autologin-user-timeout=0" "${INST_ROOT_DIRECTORY}"/etc/lightdm/lightdm.conf
        elif [ "${DM}" = "${SLIM}" ]; then
            LINE=$(grep "auto_login" "${INST_ROOT_DIRECTORY}"/etc/slim.conf)
            rpl "${LINE}" "auto_login          yes" "${INST_ROOT_DIRECTORY}"/etc/slim.conf
            LINE=$(grep "#default_user" "${INST_ROOT_DIRECTORY}"/etc/slim.conf)
            rpl "${LINE}" "default_user          ${USER}" "${INST_ROOT_DIRECTORY}"/etc/slim.conf
        elif [ "${DM}" = "${SDDM}" ]; then
            LINE=$(grep "AutoLoginEnable=" "${INST_ROOT_DIRECTORY}"/etc/kde4/kdm/kdmrc)
            rpl "${LINE}" "AutoLoginEnable=true" "${INST_ROOT_DIRECTORY}"/etc/kde4/kdm/kdmrc
            LINE=$(grep "AutoLoginUser=" "${INST_ROOT_DIRECTORY}"/etc/kde4/kdm/kdmrc)
            rpl "${LINE}" "AutoLoginUser=${USER}" "${INST_ROOT_DIRECTORY}"/etc/kde4/kdm/kdmrc
        fi
    fi
}

function install_grub() {
    echo -e "#-Installo il boot manager grub-#" >> ${FILE_LOG}
    for dir in dev proc sys; do
        [ ${DEBUG} = "TRUE" ] && echo "debug_info ${LINENO}:mount -B /${dir} ${INST_ROOT_DIRECTORY}/${dir}" &>> ${FILE_DEBUG} || \
        mount -B /${dir} ${INST_ROOT_DIRECTORY}/${dir}
    done
    [ ${DEBUG} = "TRUE" ] && echo "debug_info ${LINENO}:chroot ${INST_ROOT_DIRECTORY} grub-install --no-floppy /dev/${INST_DRIVE}" &>> ${FILE_DEBUG} || \
    chroot ${INST_ROOT_DIRECTORY} grub-install --no-floppy /dev/${INST_DRIVE}
    [ ${DEBUG} = "TRUE" ] && echo "debug_info ${LINENO}:chroot ${INST_ROOT_DIRECTORY} update-grub" &>> ${FILE_DEBUG} || \
    chroot ${INST_ROOT_DIRECTORY} update-grub
    for dir in dev proc sys; do
        [ ${DEBUG} = "TRUE" ] && echo "debug_info ${LINENO}:umount ${INST_ROOT_DIRECTORY}/${dir}" &>> ${FILE_DEBUG} || \
        umount ${INST_ROOT_DIRECTORY}/${dir}
    done
    echo -e "Installato grub su /dev/${INST_DRIVE}.">>${FILE_LOG}
}

function end() {
    [ ${DEBUG} = "TRUE" ] && echo "debug_info ${LINENO}:sync" &>> ${FILE_DEBUG} || \
    sync
    [ ${DEBUG} = "TRUE" ] && echo "debug_info ${LINENO}:umount /dev/${HOME_PARTITION}" &>> ${FILE_DEBUG} || \
    umount /dev/${HOME_PARTITION}
    [ ${DEBUG} = "TRUE" ] && echo "debug_info ${LINENO}:umount /dev/${ROOT_PARTITION}" &>> ${FILE_DEBUG} || \
    umount /dev/${ROOT_PARTITION}
    [ ${DEBUG} = "TRUE" ] && echo -e "-----------------------------------------------------------------------\ndebug_info ${LINENO}:Debug terminato:$(date)\n-----------------------------------------------------------------------" &>> ${FILE_DEBUG} || \
    echo "#-Installazione terminata $(date).-#" >> ${FILE_LOG}
    kill -9 ${PROC_ID}
}

function run_inst(){
    parse_opts
    check_root
    tail -f ${FILE_LOG} | yad --on-top --text-info --width=460 --height=200 --no-buttons --center --no-markup --tail &
    PROC_ID=$!
    get_partitions_and_disks
    [ $YES_NO = "FALSE" ] && set_options
    check_debug
    check_options
    [ $USE_HOME = "TRUE" ] && [ -z $HOME_PARTITION ] && set_home_partition
    [ -z $SWAP_PARTITION ] && set_swap_partition
    [ -z $USER ] && set_user
    [ -z $CRYPT_PASSWORD ] && set_user
    [ -z $CRYPT_ROOT_PASSWORD ] && set_root_password
    create_root_and_mount_partition
    create_home_and_mount_partition
    copy_root
    add_user
    add_sudo_user
    create_fstab
    set_locale
    set_timezone
    set_hostname
    set_autologin
    install_grub
    end
}

#---------------------------MAIN----------------------------------------
init
TEMP=$(getopt -o a:c:C:d:DfF:g:hH:i:k:l:L:n:r:s:S:t:T:u:y --long autologin:,crypt-password:,crypt-root-password:,inst-drive:,debug,format-home,file-debug:,groups:,help,home-partition:,inst-root-directory:,keyboard:,locale:,language:,hostname:,root-partition:,swap-partition:,shell-user:,type-fs:,timezone:,user:,yes -n 'yad_install_distro.sh' -- "$@")
if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi
echo -e "#---Inizio installazione: $(date)---#\n" > ${FILE_LOG}
run_inst
