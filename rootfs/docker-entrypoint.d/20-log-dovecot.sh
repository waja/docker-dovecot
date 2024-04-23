#!/bin/sh

# Set logging to STDOUT/STDERR
sed -i -e 's,#log_path =,log_path = /dev/stderr,' \
	-e 's,#info_log_path =,info_log_path = /dev/stdout,' \
	-e 's,#debug_log_path =,debug_log_path = /dev/stdout,' \
	/etc/dovecot/conf.d/10-logging.conf
