#!/bin/sh

# Parse dovecot version string from the APK database
DOVECOT_VERSION_STRING="$(
	awk -- '
		BEGIN {
			PKGID  = ""
			PKGNAM = ""
			PKGVER = ""
			
			FS = ":"
		}
		
		{
			if($1 == "C") {
				PKGID  = $2
			} else if($1 == "P") {
				PKGNAM = $2
			} else if($1 == "V") {
				PKGVER = $2
			}
			
			if(PKGID && PKGNAM && PKGVER) {
				if(PKGNAM == "dovecot") {
					print PKGNAM "-" PKGVER "." PKGID
				}
				
				PKGID  = ""
				PKGNAM = ""
				PKGVER = ""
			}
		}
	' /lib/apk/db/installed
)"

# Re-run dovecot post-install script (to generate the TLS certificates if they're missing)
tar -xf "/lib/apk/db/scripts.tar" "${DOVECOT_VERSION_STRING}.post-install" -O | sh
