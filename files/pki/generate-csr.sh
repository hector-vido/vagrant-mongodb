#!/bin/bash

if [ -z "$1" ]; then
	echo -e 'Utilização: bash generate-csr.sh hosts.csv\n\nExemplo de hosts.txt:\ndb1.example.com,10.0.0.1,rs0\ndb2.example.com,10.0.0.2,rs0'
	exit 1
fi

if [ ! -f "$1" ]; then
	echo "Arquivo '$1' não encontrado."
	exit 2
fi

while read LINE; do
	IP=$(echo $LINE | cut -d',' -f1)
	DNS=$(echo $LINE | cut -d',' -f2)
	RS=$(echo $LINE | cut -d',' -f3)
	PREFIX=$(echo $DNS | cut -d'.' -f1)
	openssl genrsa -out "$PREFIX.key" 4096
	sed -e "s/@DNS1@/$DNS/" -e "s/@IP1@/$IP/" openssl-mongodb.cnf > /tmp/openssl-temp.cnf
	openssl req -new -key "$PREFIX.key" -out "$PREFIX.csr" -subj "/CN=$DNS/O=$RS" -config /tmp/openssl-temp.cnf
done <<<$(grep -v '#' $1)

rm -rf /tmp/openssl-temp.cnf
