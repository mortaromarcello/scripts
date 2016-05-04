#!/bin/sh

if [ $?  -lt 2 ]; then
	echo "$0 <disk or partition> <image file>"
	exit
fi
if [ $(id -u) -ne 0 ]; then
	exit
fi
dd if=$1 conv=sync,noerror bs=64K | gzip -c > $2.gz
