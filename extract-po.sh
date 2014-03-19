#!/bin/bash
[ ! ${1} ] && exit
LANGUAGE="it"
OUTDIR="./locale/${LANGUAGE}/LC_MESSAGES"
[ ! -d ${OUTDIR} ] && mkdir -p -v ${OUTDIR}
xgettext -d ${1} -p ${OUTDIR} ${1}.py
