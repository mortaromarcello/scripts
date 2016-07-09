#!/usr/bin/env bash
if [ $(id -u) != 0 ]; then
	echo "$USER not is root!"
	exit
fi
apt-key adv --keyserver pgp.mit.edu --recv-keys 5044912E
cat > /etc/apt/sources.list.d/dropbox.list <<EOF
deb http://linux.dropbox.com/debian jessie main
EOF
apt update
apt install dropbox python-gpgme
