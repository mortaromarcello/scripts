#!/bin/bash

DEBUG=yes
DISTRO="$(uname -o)"
KEYBOARD="it"
LOCALE="it_IT.UTF-8 UTF-8"
SPLASH="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
"

########################################################################

########################################################################
#
########################################################################
function snapshot_configuration() {
    error_log="/var/log/snapshot_errors.log"
    work_dir="/home/work"
    snapshot_dir="/home/snapshot"
    save_work="no"
    snapshot_excludes="/tmp/snapshot_exclude.list"
    kernel_image="/vmlinuz"
    initrd_image="/initrd.img"
    stamp="datetime"
    [[ $snapshot_basename = "" ]] && snapshot_basename="snapshot" # modifica 5/09/2018
    make_md5sum="yes"
    make_isohybrid="yes"
    edit_boot_menu="no"
    iso_dir="/tmp/iso"
    boot_menu="live.cfg"
    nocopy="no"
    text_editor="/usr/bin/nano"
    pmount_fixed="yes"
    update_mlocate="yes"
    clear_geany="yes"
    ssh_pass="yes"
    patch_init_nosystemd="yes"
    username="devuan"
    #limit_cpu="no"
    #limit="50"
    rsync_option1="--delete-before"
    rsync_option2=" --delete-excluded"
    rsync_option3=""
    text_editor="/usr/bin/nano"
    mksq_opt="-info"
    mkdir -p $iso_dir/isolinux
    mkdir -p $iso_dir/live
    echo "$SPLASH" | base64 --decode > $iso_dir/isolinux/splash.png

    cat > /tmp/snapshot_exclude.list <<EOF
- /dev/*
- /cdrom/*
- /media/*
- /swapfile
- /mnt/*
- /sys/*
- /proc/*
- /tmp/*
- /live
- /persistence.conf
- /boot/grub/grub.cfg
- /boot/grub/menu.lst
- /boot/grub/device.map
- /boot/*.bak
- /boot/*.old-dkms
- /etc/udev/rules.d/70-persistent-cd.rules
- /etc/udev/rules.d/70-persistent-net.rules
- /etc/fstab
- /etc/fstab.d/*
- /etc/mtab
- /etc/blkid.tab
- /etc/blkid.tab.old
- /etc/apt/sources.list~
- /etc/crypttab
- /etc/initramfs-tools/conf.d/resume     # see remove-cryptroot and nocrypt.sh
- /etc/initramfs-tools/conf.d/cryptroot  # see remove-cryptroot and nocrypt.sh
- /home/snapshot

# Added for newer version of live-config/live-boot in wheezy
# These are only relevant here if you create a snapshot while
# you're running a live-CD or live-usb.
- /lib/live/overlay
- /lib/live/image
- /lib/live/rootfs
- /lib/live/mount
- /run/*


## Entries below are optional. They are included either for privacy
## or to reduce the size of the snapshot. If you have any large
## files or directories, you should exclude them from being copied
## by adding them to this list.
##
## Entries beginning with /home/*/ will affect all users.


# Uncomment this to exclude everything in /var/log/
#- /var/log/*

# As of version 9.2.0, current log files are truncated,
# and archived log files are excluded.
#
# The next three lines exclude everything in /var/log
# except /var/log/clamav/ (or anything else beginning with "c") and
# /var/log/gdm (or anything beginning with "g").
# If clamav log files are excluded, freshclam will give errors at boot.
#- /var/log/[a-b,A-Z]*
#- /var/log/[d-f]*
#- /var/log/[h-z]*
#- /var/log/*gz

- /var/cache/apt/archives/*.deb
- /var/cache/apt/pkgcache.bin
- /var/cache/apt/srcpkgcache.bin
- /var/cache/apt/apt-file/*
- /var/cache/debconf/*~old
- /var/lib/apt/lists/*
- /var/lib/apt/*~
- /var/lib/apt/cdroms.list
- /var/lib/aptitude/*.old
- /var/lib/dhcp/*
- /var/lib/dpkg/*~old
- /var/spool/mail/*
- /var/mail/*
- /var/backups/*.gz
#- /var/backups/*.bak
- /var/lib/dbus/machine-id
- /var/lib/live/config/*

- /usr/share/icons/*/icon-theme.cache

- /root/.aptitude
- /root/.bash_history
- /root/.disk-manager.conf
- /root/.fstab.log
- /root/.lesshst
- /root/*/.log
- /root/.local/share/*
- /root/.nano_history
- /root/.synaptic
- /root/.VirtualBox
- /root/.ICEauthority
- /root/.Xauthority


- /root/.ssh

- /home/*/.Trash*
- /home/*/.local/share/Trash/*
- /home/*/.mozilla/*/Cache/*
- /home/*/.mozilla/*/urlclassifier3.sqlite
- /home/*/.mozilla/*/places.sqlite
- /home/*/.mozilla/*/cookies.sqlite
- /home/*/.mozilla/*/signons.sqlite
- /home/*/.mozilla/*/formhistory.sqlite
- /home/*/.mozilla/*/downloads.sqlite
- /home/*/.adobe
- /home/*/.aptitude
- /home/*/.bash_history
- /home/*/.cache
- /home/*/.dbus
- /home/*/.gksu*
- /home/*/.gvfs
- /home/*/.lesshst
- /home/*/.log
- /home/*/.macromedia
- /home/*/.nano_history
- /home/*/.pulse*
- /home/*/.recently-used
- /home/*/.recently-used.xbel
- /home/*/.local/share/recently-used.xbel
- /home/*/.thumbnails/large/*
- /home/*/.thumbnails/normal/*
- /home/*/.thumbnails/fail/*
- /home/*/.vbox*
- /home/*/.VirtualBox
- /home/*/VirtualBox\ VMs
#- /home/*/.wine
- /home/*/.xsession-errors*
- /home/*/.ICEauthority
- /home/*/.Xauthority

# You might want to comment these out if you're making a snapshot for
# your own personal use, not to be shared with others.
- /home/*/.gnupg
- /home/*/.ssh
- /home/*/.xchat2

# Exclude ssh_host_keys. New ones will be generated upon live boot.
# This fixes a security hole in all versions before 9.0.9-3.
# If you really want to clone your existing ssh host keys
# in your snapshot, comment out these two lines.
- /etc/ssh/ssh_host_*_key*
- /etc/ssh/ssh_host_key*

# Examples of things to exclude in order to keep the image small:
#- /home/fred/Downloads/*
#- /home/*/Music/*
#- /home/user/Pictures/*
#- /home/*/Videos/*


# To exclude all hidden files and directories in your home, uncomment
# the next line. You will lose custom desktop configs if you do.
#- /home/*/.[a-z,A-Z,0-9]*
EOF

    ########################################################################
    # files isolinux
    ########################################################################
    cat > $iso_dir/isolinux/exithelp.cfg<<EOF
label menu
    kernel /isolinux/vesamenu.c32
    config isolinux.cfg
EOF

    cat > $iso_dir/isolinux/isolinux.cfg<<EOF
include menu.cfg
default /isolinux/vesamenu.c32
prompt 0
timeout 200
EOF

    cat > $iso_dir/isolinux/live.cfg<<EOF
label live
menu label \${DISTRO} (default)
    kernel /live/vmlinuz
    append initrd=/live/initrd.img boot=live \${netconfig_opt} \${username_opt} locales=${LOCALE} keyboard-layouts=${KEYBOARD} persistence

label nox
    menu label \${DISTRO} (text-mode)
    kernel /live/vmlinuz
    append initrd=/live/initrd.img boot=live \${netconfig_opt} 3 \${username_opt} locales=${LOCALE} keyboard-layouts=${KEYBOARD} persistence

label nomodeset
    menu label \${DISTRO} (no modeset)
    kernel /live/vmlinuz nomodeset
    append initrd=/live/initrd.img boot=live \${netconfig_opt} \${username_opt} locales=${LOCALE} keyboard-layouts=${KEYBOARD} persistence

label toram
    menu label \${DISTRO} (load to RAM)
    kernel /live/vmlinuz
    append initrd=/live/initrd.img boot=live \${netconfig_opt} toram \${username_opt} locales=${LOCALE} keyboard-layouts=${KEYBOARD} persistence

label noprobe
    menu label \${DISTRO} (no probe)
    kernel /live/vmlinuz noapic noapm nodma nomce nolapic nosmp vga=normal\n\
    append initrd=/live/initrd.img boot=live \${netconfig_opt} \${username_opt} locales=${LOCALE} keyboard-layouts=${KEYBOARD} persistence

label memtest
    menu label Memory test
    kernel /live/memtest

label chain.c32 hd0,0
    menu label Boot hard disk
    chain.c32 hd0,0

label harddisk
    menu label Boot hard disk (old way)
    localboot 0x80
EOF

    cat > $iso_dir/isolinux/menu.cfg<<EOF
menu hshift 6
menu width 64

menu title Live Media
include stdmenu.cfg
include live.cfg
label help
    menu label Help
    config prompt.cfg
EOF

    cat > $iso_dir/isolinux/stdmenu.cfg<<EOF
menu background /isolinux/splash.png
menu color title    * #FFFFFFFF *
menu color border   * #00000000 #00000000 none
menu color sel      * #ffffffff #76a1d0ff *
menu color hotsel   1;7;37;40 #ffffffff #76a1d0ff *
menu color tabmsg   * #f9f885 #00000000 *
menu color cmdline 0 #f9f885 #00000000
menu color help     37;40 #ffdddd00 #00000000 none
menu vshift 8
menu rows 12
#menu helpmsgrow 15
#menu cmdlinerow 25
#menu timeoutrow 26
#menu tabmsgrow 14
menu tabmsg Press ENTER to boot or TAB to edit a menu entry
EOF

    cat > $iso_dir/isolinux/f1.txt<<EOF
                  0fLive Media07                                07



<09F107>   This page, the help index.
<09F207>   unused
<09F307>   Boot methods for special ways of using this CD-ROM
<09F407>   Additional boot options
<09F507>   Change default language
<09F607>   unused
<09F707>   unused
<09F807>   Where to get more help
<09F907>   unused
<09F1007> Copyrights and Warranties (Debian)
You may:
- press F2 through F9 to read about the topic
- type 0fmenu07 and press ENTER to go back to the boot screen
- press ENTER to boot
EOF

    cat > $iso_dir/isolinux/f2.txt<<EOF
                  0fTITLE07                                07




You may:
- press F1 to return to the help index
- type 0fmenu07 and press ENTER to go back to the boot screen
- press ENTER to boot

EOF

    cat > $iso_dir/isolinux/f3.txt<<EOF
                  0fBOOT METHODS07                                07

0fMethods list here must correspond to entries in your boot menu. 07                                                                  09F307

0flive07
  Start the live system -- this is the default CD-ROM method.
0fnox07
  Boot to runlevel 3 (command-line-only in Refracta and some others)
0fnomodeset07
  This is useful for some sytems with nvidia graphics cards.
0ftoram07
  Copy whole read-only media to RAM before mounting root filesystem.
0fnoprobe07
  Failsafe boot method. (noapic noapm nodma nomce nolapic nosmp vga=normal)
0fmemtest07
  Start memtest to scan your RAM for errors.

To use one of these boot methods, type it at the prompt, optionally
followed by any boot parameters. For example:
  boot: live persistence acpi=off

You may:
- press F1 to return to the help index
- type 0fmenu07 and press ENTER to go back to the boot screen
- press ENTER to boot

EOF

    cat > $iso_dir/isolinux/f4.txt<<EOF
                  0fLive-Boot Options07                                07

___ Additional boot options ___

You can use the following boot parameters at the 0fboot:07 prompt, 
in combination with the boot method (see <09F307>).

0fpersistence07    Use persistent (read/write) partition or file
0fswapon07         Use local swap partitions
0fnofastboot07     Enable filesystem check
0fnomodeset07      Disable kernel mode setting
0ftoram07          Copy whole read-only media to RAM      
0fnoapic nolapic07 Disable buggy APIC interrupt routing   
0fsingle07         Single-user mode (runlevel 1)
0facpi=noirq07 or 0facpi=off07      (partly) disable ACPI                  

See 'man live-boot' or the kernel's kernel-parameters.txt file 
for more options and information.


You may:
- press F1 to return to the help index
- type 0fmenu07 and press ENTER to go back to the boot screen
- press ENTER to boot

EOF

    cat > $iso_dir/isolinux/f5.txt<<EOF
                  0fLanguage and Keyboard07                                07

You can specify the default language at the boot prompt below in combination 
with the boot method (see <09F307>) and any other options (see <09F407>). 
Examples:
  Use default boot method (live); set locale and keyboard layout for Germany:
0fboot: live config=locales,keyboard-configuration locales=de_DE.UTF-8 keyboard-layouts=de07
  Do same with refracta-lang if it is installed(experimental):
0fboot: config=refracta-lang,tzdata lang=de_DE 07

Or, at the boot menu screen, press TAB and append the boot line with the
locale options. (e.g. 0fconfig=locales locales=de_DE.UTF-807 or
0fconfig=locales,keyboard-configuration locales=de_DE.UTF-8 keyboard-layouts=de07)

  Some common locales:
France          fr_FR.UTF-8
Spain           es_ES.UTF-8
Russia          ru_RU.UTF-8

You may:
- press F1 to return to the help index
- type 0fmenu07 and press ENTER to go back to the boot screen
- press ENTER to boot
EOF

    cat > $iso_dir/isolinux/f6.txt<<EOF
                  0fTITLE07                                07




You may:
- press F1 to return to the help index
- type 0fmenu07 and press ENTER to go back to the boot screen
- press ENTER to boot
EOF

    cat > $iso_dir/isolinux/f7.txt<<EOF
                  0fTITLE07                                07




You may:
- press F1 to return to the help index
- type 0fmenu07 and press ENTER to go back to the boot screen
- press ENTER to boot
EOF

    cat > $iso_dir/isolinux/f8.txt<<EOF
                  0fRefracta!07                                07

Where to get more help:

http://www.ibiblio.org/refracta/
http://refracta.freeforums.org/
http://sourceforge.net/projects/refracta/
http://www.debian.org/
http://wiki.debian.org/
http://www.debian.org/doc/user-manuals



You may:
- press F1 to return to the help index
- type 0fmenu07 and press ENTER to go back to the boot screen
- press ENTER to boot
EOF

    cat > $iso_dir/isolinux/f9.txt<<EOF
0fTITLE07                                                    09F1007




You may:
- press F1 to return to the help index
- type 0fmenu07 and press ENTER to go back to the boot screen
- press ENTER to boot

EOF

    cat > $iso_dir/isolinux/f10.txt<<EOF
0fCOPYRIGHTS AND WARRANTIES07                                                    09F1007

Debian GNU/Linux is Copyright (C) 1993-2011 Software in the Public Interest,
and others.

The Debian GNU/Linux system is freely redistributable. After installation,
the exact distribution terms for each package are described in the
corresponding file /usr/share/doc/0bpackagename07/copyright.

Debian GNU/Linux comes with 0fABSOLUTELY NO WARRANTY07, to the extent
permitted by applicable law.

---


More information about the Debian Live project can be found at
<http://live.debian.net/>.





Press F1control and F then 1 for the help index, or ENTER to 
EOF
}


########################################################################
# file grub.cfg
########################################################################

    cat > $iso_dir/boot/grub/grub.cfg << EOF
if loadfont /font.pf2 ; then
  set gfxmode=640x480
  insmod efi_gop
  insmod efi_uga
  insmod video_bochs
  insmod video_cirrus
  insmod gfxterm
  insmod jpeg
  insmod png
  terminal_output gfxterm
fi

background_image /boot/grub/splash.png
set menu_color_normal=white/black
set menu_color_highlight=dark-gray/white
set timeout=6

menuentry "devuan-live (amd64)" {
    set gfxpayload=keep
    linux   /live/vmlinuz boot=live \${username_opt}
    initrd  /live/initrd.img
}

menuentry "Other language" {
    set gfxpayload=keep
    linux /live/vmlinuz boot=live \${username_opt} locales=${LOCALE} keyboard-layouts=${KEYBOARD} 
    initrd /live/initrd.img
}

menuentry "devuan-live (load to RAM)" {
    set gfxpayload=keep
    linux   /live/vmlinuz boot=live \${username_opt} toram 
    initrd  /live/initrd.img
}

menuentry "devuan-live (failsafe)" {
    set gfxpayload=keep
    linux   /live/vmlinuz boot=live ${username_opt} noapic noapm nodma nomce nolapic nosmp vga=normal 
    initrd  /live/initrd.img
}

menuentry "Memory test" {
    linux /live/memtest
}

EOF

########################################################################
#
########################################################################
function unpatch_init() {

#  Check for previous patch.
    if $(grep -q nuke "$target_file") ; then
        echo "
It looks like $target_file was previously patched by an 
earlier version of snapshot. This patch is no longer needed.
You can comment out the added lines as shown below (or remove the
commented lines) and then run 'update-initramfs -u'.

If you don't want to do that, dont worry; 
it won't hurt anything if you leave it the way it is.

Do not change or remove the lines that begin with \"mount\"

    mount -n -o move /sys ${rootmnt}/sys
    #nuke /sys
    #ln -s ${rootmnt}/sys /sys
    mount -n -o move /proc ${rootmnt}/proc
    #nuke /proc
    #ln -s ${rootmnt}/proc /proc
"
    
        while true ; do
            echo "Open $target_file in an editor? (y/N)"
            read ans
            case $ans in
                [Yy]*)  "$text_editor" "$target_file"
                        update-initramfs -u
                        break ;;
                    *)  break ;;
            esac
        done
    echo -e "\n  Wait for the disk report to complete...\n\n"
    fi
}

########################################################################
# Function to check for old snapshots and filesystem copy
########################################################################
function check_copies() {
    # Check how many snapshots already exist and their total size
    if [[ -d $snapshot_dir ]]; then
        if ls "$snapshot_dir"/*.iso > /dev/null ; then
            snapshot_count=$(ls "$snapshot_dir"/*.iso | wc -l)
        else
            snapshot_count="0"
        fi
        snapshot_size=$(du -sh "$snapshot_dir" | awk '{print $1}')
        if [[ -z $snapshot_size ]]; then
            snapshot_size="0 bytes"
        fi
    else
        snapshot_count="0"
        snapshot_size="0 bytes"
    fi

    # Check for saved copy of the system
    if [[ -d "$work_dir"/myfs ]]; then
        saved_size=$(du -sh "$work_dir"/myfs | awk '{ print $1 }')
        saved_copy=$(echo "* You have a saved copy of the system using $saved_size of space
   located at $work_dir/myfs.")
    fi

    # Create a message to say whether the filesystem copy will be saved or not.
    if [[ $save_work = "yes" ]]; then
        save_message=$(echo "* The temporary copy of the filesystem will be saved at $work_dir/myfs.")
    else
        save_message=$(echo "* The temporary copy of the filesystem will be created at $work_dir/myfs and removed when this program finishes.")
    fi
}

########################################################################
# Create snapshot_dir and work_dir if necessary.
########################################################################
function check_directories() {
    # Don't use /media/* for $snapshot_dir or $work_dir unless it is a mounted filesystem
    snapdir_is_remote=$(echo ${snapshot_dir} | awk -F / '{ print "/" $2 "/" $3 }' | grep /media/)
    workdir_is_remote=$(echo ${work_dir} | awk -F / '{ print "/" $2 "/" $3 }' | grep /media/)
    if [ -n "$snapdir_is_remote" ] && cat /proc/mounts | grep -q ${snapdir_is_remote}; then
        echo "$snapshot_dir is mounted"
    elif [ -n "$snapdir_is_remote" ] ; then
        echo " Error.. The selected snapshot directory cannot be accessed. Do you need to mount it?"
        exit 1
    fi
    if [ -n "$workdir_is_remote" ] && cat /proc/mounts | grep -q ${workdir_is_remote}; then
        echo "$work_dir is mounted"
    elif [ -n "$workdir_is_remote" ] ; then
        echo " Error.. The selected work directory cannot be accessed. Do you need to mount it?"
        exit 1
    fi
    # Check that snapshot_dir exists
    if ! [[ -d $snapshot_dir ]]; then
        mkdir -p "$snapshot_dir"
        chmod 777 "$snapshot_dir"
    fi
    # Check that work directories exist or create them.
    if [[ $save_work = "no" ]]; then
        if [[ -d $work_dir ]]; then
            rm -rf "$work_dir"
        fi
        mkdir -p "$work_dir"/iso
        mkdir -p "$work_dir"/myfs
    elif [[ $save_work = "yes" ]]; then
        if ! [[ -d $work_dir ]]; then
            mkdir -p "$work_dir"/iso
            mkdir -p "$work_dir"/myfs
        fi
    fi
}

########################################################################
# Check disk space on mounted /, /home, /media, /mnt, /tmp
########################################################################
function check_space() {
    disk_space=$(df -h -x tmpfs -x devtmpfs -x iso9660 | awk '{ print "  " $2 "\t" $3 "\t" $4 "\t" $5 "  \t" $6 "\t\t\t" $1 }')
}

########################################################################
# Show current settings and disk space
########################################################################
function report_space() {
    echo "
 You will need plenty of free space. It is recommended that free space 
 (Avail) in the partition that holds the work directory (probably \"/\")
 should be two times the total installed system size (Used). You can 
 deduct the space taken up by previous snapshots and any saved copies of
 the system from the Used amount.

 * You have $snapshot_count snapshots taking up $snapshot_size of disk space.
 $saved_copy
 $save_message
 * The snapshot directory is currently set to $snapshot_dir
 $tmp_warning

 You can change these and other settings by editing 
 $configfile.

 Turn off NUM LOCK for some laptops.

 Current disk usage:
 (For complete listing, exit and run 'df -h')

 $disk_space
 
    hit ctrl-c to exit.  "
    sleep 5
}

########################################################################
# copy_isolinux:
########################################################################
function copy_isolinux() {
    if [[ -f /usr/lib/ISOLINUX/isolinux.bin ]] ; then
        isolinuxbin="/usr/lib/ISOLINUX/isolinux.bin"
    elif [[ -f /usr/lib/syslinux/isolinux.bin ]] ; then
        isolinuxbin="/usr/lib/syslinux/isolinux.bin"
    else
        echo "You need to install the isolinux package."
        exit 1
    fi

    ### Might need to add chain.c32 to this list of copied files:
    if [[ -f /usr/lib/syslinux/modules/bios/vesamenu.c32 ]] ; then
        vesamenu="/usr/lib/syslinux/modules/bios/vesamenu.c32"
        rsync -va /usr/lib/syslinux/modules/bios/chain.c32 "$iso_dir"/isolinux/
        rsync -va /usr/lib/syslinux/modules/bios/ldlinux.c32 "$iso_dir"/isolinux/
        rsync -va /usr/lib/syslinux/modules/bios/libcom32.c32 "$iso_dir"/isolinux/
        rsync -va /usr/lib/syslinux/modules/bios/libutil.c32 "$iso_dir"/isolinux/
    else
        vesamenu="/usr/lib/syslinux/vesamenu.c32"
    fi
    rsync -va "$isolinuxbin" "$iso_dir"/isolinux/
    rsync -va "$vesamenu" "$iso_dir"/isolinux/
}

########################################################################
#
########################################################################
function copy_kernel() {
    rsync -va "$iso_dir"/ "$work_dir"/iso/
    cp -v "$kernel_image" "$work_dir"/iso/live/
    cp -v "$initrd_image" "$work_dir"/iso/live/
    if [ -f /usr/lib/syslinux/memdisk ]; then
        cp -v /usr/lib/syslinux/memdisk "$work_dir"/iso/live/
    fi
}

########################################################################
# Copy the filesystem
########################################################################
function copy_filesystem() {
    rsync -av / myfs/ ${rsync_option1} ${rsync_option2} ${rsync_option3} \
    --exclude="$work_dir" --exclude="$snapshot_dir" --exclude-from="$snapshot_excludes"
}

########################################################################
#
########################################################################
function snapshot() {

    snapshot_configuration
    exec 2>"$error_log"

    if [[ $DEBUG = "yes" ]] ; then
        set -v -x
    fi

    # Default text editor is nano. Make sure it exists if user intends to
    # edit files before squashing the filesystem.
    if [[ $edit_boot_menu = "yes" ]] ; then
        [[ -e $text_editor ]] || { echo -e "\n Error! The text editor is set to ${text_editor},
 but it is not installed. Edit $configfile
 and set the text_editor variable to the editor of your choice.
 (examples: /usr/bin/vim, /usr/bin/joe)\n" ; exit 1 ; }
    fi

    # Test for systemd, util-linux version and patch intramfs-tools/init.
    if [[ $patch_init_nosystemd = "yes" ]] ; then
        utillinux_version=$(dpkg -l util-linux | awk '/util-linux/ { print $3 }' | cut -d. -f2)
        target_file="/usr/share/initramfs-tools/init"
        if [[ ! -h /sbin/init ]] ; then 
            if [[ $utillinux_version -ge 25 ]] ; then
                unpatch_init
            fi
        fi
    fi

    # Use the login name set in the config file. If not set, use the primary
    # user's name. If the name is not "user" then add boot option. ALso use
    # the same username for cleaning geany history.

    if [[ -n "$username" ]] ; then
        username_opt="username=$username"
    else
        username=$(awk -F":" '/1000:1000/ { print $1 }' /etc/passwd)
        if [[ $username != user ]] ; then
            username_opt="username=$username"
        fi
    fi

    # Check that kernel and initrd exist
    [[ -e "$kernel_image" ]] || kernel_message=" Warning:   Kernel image is missing. "
    [[ -e "$initrd_image" ]] || initrd_message=" Warning:   initrd image is missing. "
    if [[ -n "$kernel_message" ]] || [[ -n "$initrd_message" ]] ; then
        echo "
$kernel_message
$initrd_message

 Make sure the kernel_image and/or initrd_image  
 set in the config file are correct, and check 
 that the boot menu is also correct.
"
        exit 1
    fi

    check_copies
    check_directories
    check_space
    report_space

    # Prepare initrd to use encryption
    # This is only going to work if the latest kernel version is running.
    # (i.e. the one linked from /initrd.img)
    if [[ $initrd_crypt = "yes" ]] ; then
        if ! [[ -f /initrd.img_pre-snapshot ]] ; then
            cp -v /initrd.img /initrd.img_pre-snapshot
        fi
        if [[ -f /usr/sbin/update-initramfs.orig.initramfs-tools ]] ; then
            CRYPTSETUP=y usr/sbin/update-initramfs.orig.initramfs-tools -u
        else 
            CRYPTSETUP=y usr/sbin/update-initramfs -u
        fi
    fi

    # updated the mlocate database 
    if [[ $update_mlocate = "yes" ]]; then
        echo -e "\nRunning updatedb...\n"
        updatedb
    fi

    # The real work starts here
    cd "$work_dir"

    # @@@@  Warning: This will replace these files in custom iso_dir  @@@@@
    #copy some isolinux stuff from the system to the snapshot


    # Let iso/, vmlinuz and initrd.img get copied, even if work_dir was saved,
    # in case they have changed, unless $nocopy = yes.

    if [ "$nocopy" != "yes" ]; then
        copy_isolinux
        copy_kernel
        copy_filesystem
    fi

    # Truncate logs, remove archived logs.
    find myfs/var/log -name "*gz" -print0 | xargs -0r rm -f
    find myfs/var/log/ -type f -exec truncate -s 0 {} \;

    # Allow all fixed drives to be mounted with pmount
    if [[ $pmount_fixed = "yes" ]] ; then
        if [[ -f "$work_dir"/myfs/etc/pmount.allow ]]; then
            sed -i 's:#/dev/sd\[a-z\]:/dev/sd\[a-z\]:' "$work_dir"/myfs/etc/pmount.allow
        fi
    fi

    # Clear list of recently used files in geany for primary user.
    if [[ $clear_geany = "yes" ]] ; then
        sed -i 's/recent_files=.*;/recent_files=/' "$work_dir"/myfs/home/"$username"/.config/geany/geany.conf
    fi

    # Enable or disable password login through ssh for users (not root)
    # Remove obsolete live-config file
    if [[ -e "$work_dir"/myfs/lib/live/config/1161-openssh-server ]] ; then
        rm -f "$work_dir"/myfs/lib/live/config/1161-openssh-server
    fi

    sed -i 's/PermitRootLogin yes/PermitRootLogin without-password/' "$work_dir"/myfs/etc/ssh/sshd_config

    if [[ $ssh_pass = "yes" ]] ; then
        sed -i 's|.*PasswordAuthentication.*no|PasswordAuthentication yes|' "$work_dir"/myfs/etc/ssh/sshd_config
        sed -i 's|#.*PasswordAuthentication.*yes|PasswordAuthentication yes|' "$work_dir"/myfs/etc/ssh/sshd_config
    elif [[ $ssh_pass = "no" ]] ; then
        sed -i 's|.*PasswordAuthentication.*yes|PasswordAuthentication no|' "$work_dir"/myfs/etc/ssh/sshd_config
    fi

    # /etc/fstab should exist, even if it's empty,
    # to prevent error messages at boot
    touch "$work_dir"/myfs/etc/fstab

    # Blank out systemd machine id. If it does not exist, systemd-journald
    # will fail, but if it exists and is empty, systemd will automatically
    # set up a new unique ID.

    if [ -e "$work_dir"/myfs/etc/machine-id ]; then
        rm -f "$work_dir"/myfs/etc/machine-id
        : > "$work_dir"/myfs/etc/machine-id
    fi

    # add some basic files to /dev
    mknod -m 622 "$work_dir"/myfs/dev/console c 5 1
    mknod -m 666 "$work_dir"/myfs/dev/null c 1 3
    mknod -m 666 "$work_dir"/myfs/dev/zero c 1 5
    mknod -m 666 "$work_dir"/myfs/dev/ptmx c 5 2
    mknod -m 666 "$work_dir"/myfs/dev/tty c 5 0
    mknod -m 444 "$work_dir"/myfs/dev/random c 1 8
    mknod -m 444 "$work_dir"/myfs/dev/urandom c 1 9
    chown -v root:tty "$work_dir"/myfs/dev/{console,ptmx,tty}

    ln -sv /proc/self/fd "$work_dir"/myfs/dev/fd
    ln -sv /proc/self/fd/0 "$work_dir"/myfs/dev/stdin
    ln -sv /proc/self/fd/1 "$work_dir"/myfs/dev/stdout
    ln -sv /proc/self/fd/2 "$work_dir"/myfs/dev/stderr
    ln -sv /proc/kcore "$work_dir"/myfs/dev/core
    ln -sv /run/shm "$work_dir"/myfs/dev/shm
    mkdir -v "$work_dir"/myfs/dev/pts

    # Need to define $filename here (moved up from genisoimage)
    # and use it as directory name to identify the build on the cdrom.
    # and put package list inside that directory
    if [[ $stamp = "datetime" ]]; then
        # use this variable so iso and md5 have same time stamp
        #filename="$snapshot_basename"-$(date +%Y%m%d_%H%M).iso
        filename="$snapshot_basename"-$(date +%Y%m%d%H%M).iso
    else
        n=1
        while [[ -f "$snapshot_dir"/snapshot$n.iso ]]; do
            ((n++))
        done
        filename="$snapshot_basename"$n.iso
    fi

    # Prepend the dir name with a constant,
    # so you can find and delete the old ones.
    #
    dir_prefix="pkglist"

    for dir in "$work_dir"/iso/"$dir_prefix"* ; do
        rm -r "$dir"
    done
    mkdir -p "$work_dir"/iso/"${dir_prefix}_${filename%.iso}"
    dpkg -l | egrep "ii|hi" | awk '{ print $2 }' > "$work_dir"/iso/"${dir_prefix}_${filename%.iso}"/package_list

    # Add the Release Notes to the iso
    if [[ -f /usr/share/doc/_Release_Notes/Release_Notes ]] ; then
        rsync -va /usr/share/doc/_Release_Notes/Release_Notes "$work_dir"/iso/
    fi

    # Create the boot menu unless iso_dir or boot_menu is not default.
    if [[ -n "$DISTRO" ]] ; then
        live_config_version=$(dpkg -l live-config | awk '/live-config/ { print $3 }' | cut -d. -f1)
        if [[ $live_config_version -gt 3 ]] ; then
            CONFIGS="components"
        else
            CONFIGS="config"
        fi

        sed -i "s:\${DISTRO}:$DISTRO:g" "$work_dir"/iso/isolinux/"$boot_menu"
        sed -i "s:\${netconfig_opt}:$netconfig_opt:g" "$work_dir"/iso/isolinux/"$boot_menu"
        sed -i "s:\${username_opt}:$username_opt:g" "$work_dir"/iso/isolinux/"$boot_menu"
        #sed -i "s:\${CONFIGS}:$CONFIGS:g" "$work_dir"/iso/isolinux/"$boot_menu"
    fi

    # Clear configs from /etc/network/interfaces, wicd and NetworkManager
    # so they aren't stealthily included in the snapshot.
    if [[ -z $netconfig_opt ]] ; then
        echo "# The loopback network interface
auto lo
iface lo inet loopback
" > "$work_dir"/myfs/etc/network/interfaces
        rm -f "$work_dir"/myfs/var/lib/wicd/configurations/*
        rm -f "$work_dir"/myfs/etc/NetworkManager/system-connections
    fi

    # Pause to edit the boot menu or anything else in $work_dir
    if [[ $edit_boot_menu = "yes" ]]; then
        echo "
 You may now go to another virtual console to edit any files in the work
 directory, or hit ENTER and edit the boot menu.
 "
        read -p " "
        "$text_editor" "$work_dir"/iso/isolinux/"$boot_menu"
        # "$text_editor" "$work_dir"/iso/boot/grub/"$grub_menu"
    fi

    # Squash the filesystem copy
    echo "Squashing the filesystem..."
    mksquashfs "$work_dir"/myfs/ "$work_dir"/iso/live/filesystem.squashfs ${mksq_opt}
    cp -va "$work_dir"/iso/live/filesystem.squashfs "$snapshot_dir"/filesystem.squashfs-$(date +%Y%m%d_%H%M)

    # This code is redundant, because $work_dir gets removed later, but
    # it might help by making more space on the hard drive for the iso.
    if [[ $save_work = "no" ]]; then
        rm -rf myfs
    fi

    # create the iso file, make it isohybrid
    # create md5sum file for the iso
    echo "Creating CD/DVD image file..."

    # If isohdpfx.bin gets moved again, maybe use:   isohdpfx=$(find /usr/lib/ -name isohdpfx.bin)
    if [[ $make_isohybrid = "yes" ]]; then
        if [[ -f /usr/lib/syslinux/mbr/isohdpfx.bin ]] ; then
            isohybrid_opt="-isohybrid-mbr /usr/lib/syslinux/mbr/isohdpfx.bin"
        elif [[ -f /usr/lib/syslinux/isohdpfx.bin ]] ; then
            isohybrid_opt="-isohybrid-mbr /usr/lib/syslinux/isohdpfx.bin"
        elif [[ -f /usr/lib/ISOLINUX/isohdpfx.bin ]] ; then
            isohybrid_opt="-isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin"
        else
            echo "Can't create isohybrid.  File: isohdpfx.bin not found. The resulting image will be a standard iso file."
        fi
    fi

    xorriso -as mkisofs -r -J -joliet-long -l ${isohybrid_opt} \
    -partition_offset 16 -V "snapshot-live-cd"  -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot \
    -boot-load-size 4 -boot-info-table -o "$snapshot_dir"/"$filename" iso/ 

    if [[ $make_md5sum = "yes" ]]; then
        cd "$snapshot_dir"
        md5sum "$filename" > "$filename".md5
        cd "$work_dir"
    fi

    # Cleanup
    if [[ $save_work = "no" ]]; then
        echo "Cleaning..."
        cd /
        rm -rf "$work_dir"
    else
        rm "$work_dir"/iso/live/filesystem.squashfs
    fi

    echo "All finished! "
}

########################################################################
#
########################################################################

until [ -z "${1}" ]
do
    case ${1} in
        -d | --distro)
            shift
            DISTRO=${1}
            ;;
        -k | --keyboard)
            shift
            KEYBOARD=${1}
            ;;
        -l | --locale)
            shift
            LOCALE=${1}
            ;;
    # modifica 5/09/2018
        -s | --snapshot)
            shift
            snapshot_basename=${1}
            ;;
    # fine modifica
        -u | --username)
            shift
            username=${1}
            ;;
        *)
            shift
            ;;
    esac
done

snapshot
