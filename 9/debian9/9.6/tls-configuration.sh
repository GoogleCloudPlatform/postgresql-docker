#!/bin/bash
#
# Copyright 2021 Google LLC
#
# Permission to use, copy,
# modify, and distribute this software and its documentation for any purpose,
# without fee, and without a written agreement is hereby granted, provided that
# the above copyright notice and this paragraph and the following two paragraphs
# appear in all copies.
#
# IN NO EVENT SHALL GOOGLE BE LIABLE TO ANY PARTY
# FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING
# LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION,
# EVEN IF GOOGLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# GOOGLE SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT
# NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE. THE SOFTWARE PROVIDED HEREUNDER IS ON AN "AS IS" BASIS,
# AND GOOGLE HAS NO OBLIGATIONS TO PROVIDE MAINTENANCE, SUPPORT, UPDATES,
# ENHANCEMENTS, OR MODIFICATIONS.
#
#
# POSTGRES_TLS_LOCATION
# Optional environment variable can be used to define location of server.key and server.crt files.
# By default it's $PGDATA/../tls,
# if POSTGRES_TLS_LOCATION begins with / -- it's absolute
# otherwise the location will be $PGDATA/$POSTGRES_TLS_LOCATION

pgdata=${PGDATA:-/var/lib/postgresql/data}
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

