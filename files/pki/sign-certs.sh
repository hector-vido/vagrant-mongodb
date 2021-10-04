#!/bin/bash

if [ -z "$1" ]; then
	echo -e 'Utilização: bash sign-certs.sh hosts.csv\n\nExemplo de hosts.txt:\ndb1.example.com,10.0.0.1,rs0\ndb2.example.com,10.0.0.2,rs0'
	exit 1
fi

if [ ! -f "$1" ]; then
	echo "Arquivo '$1' não encontrado."
	exit 2
fi

if [ ! -f ca.key ] || [ ! -f ca.crt ]; then
	openssl genrsa -out ca.key 4096
	openssl req -new -x509 -days 1826 -key ca.key -out ca.crt -subj '/CN=CA MongoDB'
fi

while read LINE; do
        IP=$(echo $LINE | cut -d',' -f1)
        DNS=$(echo $LINE | cut -d',' -f2)
        RS=$(echo $LINE | cut -d',' -f3)
	PREFIX=$(echo $DNS | cut -d'.' -f1)
	if [ ! -f "$PREFIX.csr" ] || [ ! -f "$PREFIX.key" ]; then
		echo "Arquivo $PREFIX.crt/$PREFIX.key não encontrado."
		exit 3
	fi
	sed -e "s/@DNS1@/$DNS/" -e "s/@IP1@/$IP/" openssl-mongodb.cnf > /tmp/openssl-temp.cnf
	openssl x509 -sha256 -req -days 365 -in "$PREFIX.csr" -CA ca.crt -CAkey ca.key -CAcreateserial -out "$PREFIX.crt" -extfile /tmp/openssl-temp.cnf -extensions v3_req
	cat "$PREFIX.crt" "$PREFIX.key" > "$PREFIX.pem"
done <<<$(grep -v '#' $1)

rm -rf /tmp/openssl-temp.cnf
