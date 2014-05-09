#!/bin/bash
if [ ! ${2} ]; then
	echo "${0} <file(without extension)> <language>"
	exit
fi
LANGUAGE=${2}
OUTDIR="./locale/${LANGUAGE}/LC_MESSAGES"
[ ! -d ${OUTDIR} ] && mkdir -p -v ${OUTDIR}
xgettext -d ${1} -p ${OUTDIR} ${1}.py
