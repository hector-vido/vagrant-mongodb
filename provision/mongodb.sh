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
apt-get install -y vim wget gnupg git lvm2 xfsprogs
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -

echo 'deb http://repo.mongodb.org/apt/debian buster/mongodb-org/4.4 main' > /etc/apt/sources.list.d/mongodb-org-4.4.list
apt-get update
apt-get install -y mongodb-org

# Logrotate
mkdir -p /var/run/mongodb
chown mongodb: /var/run/mongodb
cp /vagrant/files/mongodb /etc/logrotate.d/
if [ "$(grep pidFilePath /etc/mongod.conf)" == '' ]; then
	sed -Ei 's,/usr/share/zoneinfo,/usr/share/zoneinfo\n  pidFilePath: /var/run/mongodb/mongod.pid,' /etc/mongod.conf
	sed -Ei 's,/var/log/mongodb/mongod.log,/var/log/mongodb/mongod.log\n  logRotate: reopen,' /etc/mongod.conf
fi

systemctl restart mongod
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
