#!/bin/bash
[[ $# -le 0 ]] && echo "$0: <drive>" && exit
kvm -m 1024 -hda $1 -drive if=pflash,format=raw,file=/usr/share/qemu/OVMF.fd
