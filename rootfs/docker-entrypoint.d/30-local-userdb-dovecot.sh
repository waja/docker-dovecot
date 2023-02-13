#!/bin/sh

# Create needed directory
if [ ! -d /var/lib/dovecot/sqlite ]; then
	mkdir -p /var/lib/dovecot/sqlite
fi
# https://doc.dovecot.org/configuration_manual/authentication/proxies/#example-password-forwarding-sql-configuration
if [ ! -f /var/lib/dovecot/sqlite/dct.db ]; then
	command -v sqlite3 || apk add sqlite
	echo 'CREATE TABLE IF NOT EXISTS "proxy" ("domain" varchar(255) NOT NULL,"host" varchar(16) DEFAULT NULL,"user" varchar(255),"destuser" varchar(255),PRIMARY KEY("domain", "user"));' | sqlite3 /var/lib/dovecot/sqlite/dct.db
fi
