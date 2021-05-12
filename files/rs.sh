#!/bin/sh

for X in 10 20 30; do
	ssh -o stricthostkeychecking=no 172.27.11.$X "mongo --eval '//'"
	while [ "$?" -ne 0 ]; do
		sleep 1
		ssh -o stricthostkeychecking=no 172.27.11.$X "mongo --eval '//'"
	done
done

cat <<'EOF' | mongo
rs.initiate( {
   _id : "rs0",
   members: [
      { _id: 0, host: "172.27.11.10:27017" },
      { _id: 1, host: "172.27.11.20:27017" },
      { _id: 2, host: "172.27.11.30:27017" }
   ]
})
EOF
