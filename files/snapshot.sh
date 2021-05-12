#!/bin/bash

echo 'db.fsyncLock()' | mongo

lvcreate --name mongo_snap --size 1G --snapshot /dev/mongo/mongo_data
mount /dev/mongo/mongo_snap /mnt

ssh 172.27.11.30 'systemctl stop mongod && rm -rf /var/lib/mongodb/*'
scp -rv /mnt/* 172.27.11.30:/var/lib/mongodb/
ssh 172.27.11.30 'chown -R mongodb: /var/lib/mongodb/ && systemctl start mongod'

umount /mnt
lvremove --yes /dev/mongo/mongo_snap

echo 'db.fsyncUnlock()' | mongo
