#!/bin/bash
#
# semplice script di installazione
#
#-----------------------------------------------------------------------
#
#-----------------------------------------------------------------------

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
HOSTNAME="devuan"
if [ "$(cat /etc/group|grep android)" ]; then
	ADD_GROUPS="cdrom,floppy,audio,dip,video,plugdev,scanner,netdev,android"
else
	ADD_GROUPS="cdrom,floppy,audio,dip,video,plugdev,scanner,netdev"
fi
TIMEZONE="Europe/Rome"
SHELL_USER="/bin/bash"
AUTOLOGIN="true"

#-----------------------------------------------------------------------

function help() {
	echo -e "
${0} <opzioni>
Installa la Live su un disco.
	-a | --autologin <true/false>          :Autologin utente. (default 'true').
	-c | --crypt-password <password>       :Password cifrata utente.
	-C | --crypt-root-password <password>  :Password cifrata root.
	-d | --inst-drive <drive>              :Drive di installazione per grub.
	-f | --format-home <si/no>             :Se 'si', formatta la partizione home.
	-g | --groups <group1,...,groupn>      :Gruppi addizionali a cui l'utente appartiene.
	-h | --help                            :Stampa questa messaggio.
	-H | --home-partition <partition>      :Partizione di home.
	-i | --inst-root-directory <directory> :Directory di installazione (default '/mnt/distro').
	-k | --keyboard                        :Tipo di tastiera (default 'it').
	-l | --locale                          :Tipo di locale (default 'it_IT.UTF-8 UTF-8').
	-L | --language                        :Lingua (default 'it_IT.UTF-8').
	-n | --hostname                        :Nome hostname (default 'devuan').
	-r | --root-partition <partition>      :Partizione di root (default '/dev/sda1').
	-s | --swap-partition <partition>      :Partizione di swap.
	-S | --shell-user                      :Shell user (default '/bin/bash').
	-t | --type-fs <type fs>               :Tipo di file system (default 'ext4').
	-T | --timezone <timezone>             :Timezone (default 'Europe/Rome'.
	-u | --user                            :Nome utente.
	-y | --yes                             :Non interattivo.
"
}

function check_root() {
	if [ ${UID} != 0 ]; then
		echo "Devi essere root per eseguire questo script."
		exit
	fi
}

function check_script() {
	MESSAGE1="Con l'opzione -y deve essere specificato lo user, la password cryptata dello user e la password cryptata di root."
	if [ ${YES_NO} = "si" ] && [ -z ${USER} ]; then
		echo "${MESSAGE1}"; exit
	fi
	if [ ${YES_NO} = "si" ] && [ -z ${CRYPT_PASSWORD} ]; then
		echo "${MESSAGE1}"; exit
	fi
	if [ ${YES_NO} = "si" ] && [ -z ${CRYPT_ROOT_PASSWORD} ]; then
		echo "${MESSAGE1}"; exit 
	fi
	echo "Script verificato. OK."
}

put_info() {
	echo "Partizione di installazione (root):" ${ROOT_PARTITION}
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
	echo "Gruppi                            :" "${ADD_GROUPS}"
	echo "Locale                            :" "${LOCALE}"
	echo "Tastiera                          :" "${KEYBOARD}"
	echo "Lingua                            :" "${LANG}"
	echo "Timezone                          :" "${TIMEZONE}"
	echo "Shell user                        :" "${SHELL_USER}"
}

function create_root_and_mount_partition() {
	IS_MOUNTED=$(mount|grep ${ROOT_PARTITION})
	if [ ! -z "$IS_MOUNTED" ]; then
		echo "La partizione è montata. Esco."
		exit
	fi
	if [ "${YES_NO}" = "no" ]; then
		read -p "Attenzione! la partizione ${ROOT_PARTITION} sarà formattata! Continuo?(si/no): " YES_NO
	fi
	if [ -z "${YES_NO}" ] || [ ! "${YES_NO}" = "si" ]; then
		exit
	fi
	mkfs -t ${TYPE_FS} ${ROOT_PARTITION}
	UUID_ROOT_PARTITION=$(blkid -o value -s UUID ${ROOT_PARTITION})
	mkdir -p ${INST_ROOT_DIRECTORY}
	mount ${ROOT_PARTITION} ${INST_ROOT_DIRECTORY}
}

function create_home_and_mount_partition() {
	IS_MOUNTED=$(mount|grep ${HOME_PARTITION})
	if [ ! -z "$IS_MOUNTED" ]; then
		echo "La partizione è montata. Esco."
	exit
	fi
	if [ ! -z ${HOME_PARTITION} ]; then
		if [ ${FORMAT_HOME} = "si" ]; then
			if [ "${YES_NO}" = "no" ]; then
				read -p "Attenzione! la partizione ${HOME_PARTITION} sarà formattata! Continuo?(si/no): " YES_NO
			fi
			if [ "${YES_NO}" = "no" ] || [ -z "${YES_NO}" ]; then
				exit
			fi
			mkfs -t ${TYPE_FS} ${HOME_PARTITION}
		fi
		UUID_HOME_PARTITION=$(blkid -o value -s UUID ${HOME_PARTITION})
		mkdir -p ${INST_ROOT_DIRECTORY}/home
		mount ${HOME_PARTITION} ${INST_ROOT_DIRECTORY}/home
	fi
}

function copy_root() {
	SQUASH_FS="/lib/live/mount/rootfs/filesystem.squashfs"
	cp -av ${SQUASH_FS}/* ${INST_ROOT_DIRECTORY}
}

function remove_users() {
	for user in $(ls ${INST_ROOT_DIRECTORY}/home); do
		if [ "$user" != "lost+found" ] && [ "$user" != "$USER" ]; then
			chroot ${INST_ROOT_DIRECTORY} userdel -rf "$user"
		fi
	done
}

function add_user() {
	if [ -z ${USER} ]; then
		read -p "Digita la username: " USER
		if [ -z "${USER}" ]; then
			read -p "Bisogna digitare un nome. Prova ancora o premi 'enter': " USER
			[ -z "${USER}" ] && echo "Installazione abortita!" && exit -1
		fi
	fi
	remove_users
	if [ -z ${CRYPT_PASSWORD} ]; then
		while true; do
			read -s -p "Digita la password: " USER_PASSWORD
			echo
			if [ -z "${USER_PASSWORD}" ]; then
				read -s -p "Password obbligatoria. Prova ancora o premi 'enter': " USER_PASSWORD
				echo
				[ -z "${USER_PASSWORD}" ] && echo "Installazione abortita!" && exit -1
			fi
			read -s -p "conferma la password: " USER_PASSWORD2
			echo
			if [ "$USER_PASSWORD2" == "$USER_PASSWORD" ]; then
				break
			else
				echo "Le password non coincidono. Riprova"
			fi
		done
	fi
	CRYPT_PASSWORD=$(perl -e 'print crypt($ARGV[0], "password")' "${USER_PASSWORD}")
	chroot ${INST_ROOT_DIRECTORY} useradd -G ${ADD_GROUPS} -s
	${SHELL_USER} -u 1000 -o -m -p "$CRYPT_PASSWORD" "$USER"
	if [ $? -eq 0 ]; then
		echo "User has been added to system!" 
	else
		echo "Failed to add a user!";
		exit
	fi
}

function add_sudo_user() {
	chroot ${INST_ROOT_DIRECTORY} gpasswd -a "${USER}" sudo
	cat > ${INST_ROOT_DIRECTORY}/etc/sudoers.d/nopasswd <<EOF
${USER} ALL=(ALL) NOPASSWD: ALL
EOF
}

function change_root_password() {
	if [ -z ${CRYPT_ROOT_PASSWORD} ]; then
	while true; do
		read -s -p "Digita la password per l'amministratore root: " ROOT_PASSWORD
		echo
		if [ -z "${ROOT_PASSWORD}" ]; then
			read -s -p "Password obbligatoria. Prova ancora o premi 'enter': " ROOT_PASSWORD
			echo
			[ -z "${ROOT_PASSWORD}" ] && echo "Installazione abortita!" && exit -1
		fi
		read -s -p "conferma la password: " ROOT_PASSWORD2
		echo
		if [ "$ROOT_PASSWORD2" == "$ROOT_PASSWORD" ]; then
			break
		else
			echo "Le password non coincidono. Riprova"
		fi
	done
	CRYPT_ROOT_PASSWORD=$(perl -e 'print crypt($ARGV[0], "password")' "${ROOT_PASSWORD}")
	fi
	chroot ${INST_ROOT_DIRECTORY} bash -c "echo root:${CRYPT_ROOT_PASSWORD} | chpasswd -e"
}

function create_fstab() {
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
	UUID_SWAP_PARTITION=$(blkid -o value -s UUID ${SWAP_PARTITION})
	cat >> ${INST_ROOT_DIRECTORY}/etc/fstab <<EOF
UUID=${UUID_SWAP_PARTITION} none swap sw 0 0
EOF
	fi
}

function set_locale() {
	LINE=$(cat ${INST_ROOT_DIRECTORY}/etc/locale.gen|grep "${LOCALE}")
	sed -i "s/${LINE}/${LOCALE}/" ${INST_ROOT_DIRECTORY}/etc/locale.gen
	chroot ${INST_ROOT_DIRECTORY} locale-gen
	chroot ${INST_ROOT_DIRECTORY} update-locale LANG=${LANG}
	LINE=$(cat ${INST_ROOT_DIRECTORY}/etc/default/keyboard|grep "XKBLAYOUT")
	sed -i "s/${LINE}/XKBLAYOUT=\"${KEYBOARD}\"/" ${INST_ROOT_DIRECTORY}/etc/default/keyboard
}

function set_timezone() {
	cat > ${INST_ROOT_DIRECTORY}/etc/timezone <<EOF
${TIMEZONE}
EOF
}

function set_hostname() {
	cat > ${INST_ROOT_DIRECTORY}/etc/hostname <<EOF
${HOSTNAME}
EOF
	cat > ${INST_ROOT_DIRECTORY}/etc/hosts <<EOF
127.0.0.1       localhost
127.0.1.1       ${HOSTNAME}
::1             localhost ip6-localhost ip6-loopback
fe00::0         ip6-localnet
ff00::0         ip6-mcastprefix
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
EOF
}

function set_autologin() {
	if [ ${AUTOLOGIN} = "true" ]; then
		DM=$(cat ${INST_ROOT_DIRECTORY}/etc/X11/default-display-manager)
		if [ "${DM}" = "/usr/sbin/lightdm" ]; then
			LINE=$(cat ${INST_ROOT_DIRECTORY}/etc/lightdm/lightdm.conf|grep "#autologin-user=")
			sed -i "s/${LINE}/autologin-user=\"${USER}\"/" ${INST_ROOT_DIRECTORY}/etc/lightdm/lightdm.conf
		fi
		if [ "${DM}" = "/usr/bin/slim" ]; then
			LINE=$(cat ${INST_ROOT_DIRECTORY}/etc/slim.conf|grep "auto_login")
			sed -i "s/${LINE}/auto_login          yes/" ${INST_ROOT_DIRECTORY}/etc/slim.conf
			LINE=$(cat ${INST_ROOT_DIRECTORY}/etc/slim.conf|grep "#default_user")
			sed -i "s/${LINE}/default_user          ${USER}/" ${INST_ROOT_DIRECTORY}/etc/slim.conf
		fi
	fi
}

function update_minidlna() {
	sed -i "s/live-user/${USER}/" ${INST_ROOT_DIRECTORY}/etc/minidlna.conf
}

function install_grub() {
	for dir in dev dev/pts proc sys; do
		mount --bind /${dir} ${INST_ROOT_DIRECTORY}/${dir}
	done
	chroot ${INST_ROOT_DIRECTORY} grub-install --no-floppy ${INST_DRIVE}
	chroot ${INST_ROOT_DIRECTORY} update-grub
	for dir in dev/pts dev proc sys; do
		umount -v ${INST_ROOT_DIRECTORY}/${dir}
	done
}

function end() {
	sync
	if [ -z ${HOME_PARTITION} ]; then
		umount ${HOME_PARTITION}
	fi
	if [ -z ${ROOT_PARTITION} ]; then
		umount ${ROOT_PARTITION}
	fi
	echo "Installazione terminata."
}

function run_inst {
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
	set_autologin
	install_grub
	end
}

#------------------------------------------------------------------------

until [ -z "${1}" ]
do
	case ${1} in
		-a | --autologin)
			shift
			AUTOLOGIN=${1}
			;;
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
