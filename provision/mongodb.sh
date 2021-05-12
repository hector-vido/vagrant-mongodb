#!/bin/bash

# Copia a chave SSH
mkdir -p /root/.ssh
cp /vagrant/files/key /root/.ssh/id_rsa
cp /vagrant/files/key.pub /root/.ssh/id_rsa.pub
cp /vagrant/files/key.pub /root/.ssh/authorized_keys
chmod 400 /root/.ssh/*

# Cria swap se não existir
if [ "$(swapon -v)" == '' ]; then
	dd if=/dev/zero of=/swapfile bs=1M count=512
	chmod 0600 /swapfile
	mkswap /swapfile
	swapon /swapfile
	echo '/swapfile       swap    swap    defaults        0       0' >> /etc/fstab
fi

apt-get update
apt-get install -y vim wget gnupg git
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -

echo "deb http://repo.mongodb.org/apt/debian buster/mongodb-org/4.4 main" > /etc/apt/sources.list.d/mongodb-org-4.4.list
apt-get update
apt-get install -y mongodb-org

systemctl start mongod
systemctl enable mongod

# Dados de teste
if [ "$2" -eq 1 ]; then
	git clone --depth 1 https://github.com/huynhsamha/quick-mongo-atlas-datasets.git
	cd quick-mongo-atlas-datasets
	mongorestore
fi

if [ "$1" == 'rs' ]; then
	sed -Ei 's,#replication:,replication:\n  replSetName: "rs0",' /etc/mongod.conf
	sed -Ei 's,127\.0\.0\.1,0.0.0.0,' /etc/mongod.conf
	systemctl restart mongod
	if [ "$HOSTNAME" == 'db1' ]; then
		sh /vagrant/files/rs.sh
	fi
fi
