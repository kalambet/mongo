#!/bin/bash
set -e

if [ "${1:0:1}" = '-' ]; then
	set -- mongod "$@"
fi

adduser mongodb root
chmod 775 /mnt/mngdata

su -c "mkdir -p /mnt/mngdata/mngdb" mongodb
ln -sf /mnt/mngdata/mngdb /data/db
chown -h mongodb:mongodb /data/db

su -c "mkdir -p /mnt/mngdata/mngconfig" mongodb
ln -sf /mnt/mngdata/mngconfig /data/configdb
chown -h mongodb:mongodb /data/configdb

deluser mongodb root
chmod 755 /mnt/mngdata

# allow the container to be started with `--user`
if [ "$1" = 'mongod' -a "$(id -u)" = '0' ]; then
	#chown -R mongodb /data/configdb /data/db
	exec gosu mongodb "$BASH_SOURCE" "$@"
fi

if [ "$1" = 'mongod' ]; then
	numa='numactl --interleave=all'
	if $numa true &> /dev/null; then
		set -- $numa "$@"
	fi
fi

exec "$@"
