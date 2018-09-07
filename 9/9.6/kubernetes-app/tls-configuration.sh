#!/bin/bash
#
# (c) Google LLC 2018
#
# POSTGRES_TLS_LOCATION
# Optional environment variable can be used to define location of server.key and server.crt files.
# By default it's $PGDATA/../tls,
# if POSTGRES_TLS_LOCATION begins with / -- it's absolute
# otherwise the location will be $PGDATA/$POSTGRES_TLS_LOCATION

pgdata=${PGDATA:+/var/lib/postgresql/data}
tlslocation=$pgdata/../tls
if [[ -v POSTGRES_TLS_LOCATION ]]; then
	if [[ ${POSTGRES_TLS_LOCATION##/*} ]]; then		## doesn't begin with /
		tlslocation=$pgdata/$POSTGRES_TLS_LOCATION
	else
		tlslocation=$POSTGRES_TLS_LOCATION
	fi
fi

if [[ -d $tlslocation ]]; then
	if [[ ! -f $tlslocation/server.crt || ! -f $tlslocation/server.key ]]; then
		echo "There are no $tlslocation/server.crt or $tlslocation/server.key files."
		exit
	fi
	echo "Using $tlslocation/server.crt and $tlslocation/server.key files."
	cp $tlslocation/server.crt $tlslocation/server.key $pgdata
	chmod 600 $pgdata/server.crt $pgdata/server.key
	sed -i 's/#ssl = off/ssl = on/' $pgdata/postgresql.conf
fi

