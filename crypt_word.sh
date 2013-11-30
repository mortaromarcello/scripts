#!/bin/bash
if [ -z ${1} ]; then echo "${0} <word>";exit; fi
CRYPT_PASSWORD=$(perl -e 'print crypt($ARGV[0], "password")' $1)
echo $CRYPT_PASSWORD
