#!/bin/bash

# Dados de teste
# git clone https://github.com/huynhsamha/quick-mongo-atlas-datasets.git

apt-get update
apt-get install -y vim curl wget gnupg
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -

echo "deb http://repo.mongodb.org/apt/debian buster/mongodb-org/4.4 main" > /etc/apt/sources.list.d/mongodb-org-4.4.list
apt-get update
apt-get install -y mongodb-org

systemctl start mongod
systemctl enable mongod
