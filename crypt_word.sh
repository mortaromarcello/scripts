#!/bin/bash
read -s -p "Inserisci la parola da criptare: " PAROLA
CRYPT_PASSWORD=$(perl -e 'print crypt($ARGV[0], "password")' $PAROLA)
echo -e "\nParola criptata:" $CRYPT_PASSWORD
