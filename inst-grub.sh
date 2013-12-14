#!/bin/bash
if [ -z ${3} ]; then
  exit
fi
PARTITION=${1}
INST_ROOT_DIRECTORY=${2}
INST_DRIVE=${3}
mount ${PARTITION} ${INST_ROOT_DIRECTORY}

for dir in dev proc sys; do
  mount -B /${dir} ${INST_ROOT_DIRECTORY}/${dir}
done
chroot ${INST_ROOT_DIRECTORY} grub-install --no-floppy ${INST_DRIVE}
for dir in dev proc sys; do
  umount ${INST_ROOT_DIRECTORY}/$dir
done
umount ${INST_ROOT_DIRECTORY}
