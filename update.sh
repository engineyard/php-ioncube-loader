#!/bin/sh

set -e nounset
set -e errexit

VERSION="4.6.1"
DATE="$(date +"%a, %d %b %Y %T %z")"
YEAR="$(date +"%Y")"

IONCUBE_URL="http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz"
IONCUBE_TEMP="$(mktemp -d -t tarb.XXXXX)"
TARBALL="$IONCUBE_TEMP/ioncube_loaders.tar.gz"

errexit() {
	echo "$1"
	exit 1
}

if [ ! -d DEBIAN ]; then
	errexit "Run from root of packaging directory."
fi

CWD=$(pwd)

# Check available commands
for cmd in curl
do
	command -v $cmd > /dev/null || errexit "$cmd required."
done

if [ ! -f $TARBALL ]; then
	curl -s -L $IONCUBE_URL -o $TARBALL
fi

cd $IONCUBE_TEMP && tar -xzvf $TARBALL

for PHP_VERSION in 5.3 5.4 5.5; do
{
	sofile="ioncube/ioncube_loader_lin_${PHP_VERSION}.so"
	if [ ! -f  $sofile ]; then
		errexit "$sofile not found"
	fi

	if [ $PHP_VERSION = "5.5" ]; then
		EXTENSION_DIR="/usr/lib/php5/20121212/"
		EXTENSION_CONFIG="/etc/php5/mods-available/"
	fi
	
	if [ $PHP_VERSION = "5.4" ]; then
		EXTENSION_DIR="/usr/lib/php5/20100525/"
		EXTENSION_CONFIG="/etc/php5/mods-available/"
	fi

	if [ $PHP_VERSION = "5.3" ]; then
		EXTENSION_DIR="/usr/lib/php5/20090626/"
		EXTENSION_CONFIG="/etc/php5/conf.d/"
	fi

	# Copy skeleton DEBIAN packaging
	mkdir -p "${CWD}/${PHP_VERSION}/DEBIAN"
	cp -r ${CWD}/DEBIAN/* "${CWD}/${PHP_VERSION}/DEBIAN"

	# Correct extension directory exists
	mkdir -p "${CWD}/${PHP_VERSION}/${EXTENSION_DIR}"
	mkdir -p "${CWD}/${PHP_VERSION}/${EXTENSION_CONFIG}"
	# Directory for changelog
	mkdir -p "${CWD}/${PHP_VERSION}/usr/share/doc/ioncube-loader/"

	cp $sofile "${CWD}/${PHP_VERSION}/${EXTENSION_DIR}"

	# Changelog
	gzip -9 > "${CWD}/${PHP_VERSION}/usr/share/doc/ioncube-loader/changelog.Debian.gz" <<EOF
php-ioncube-loader (${VERSION}) unstable; urgency=low

  * Release for ${PHP_VERSION}.

 -- Engine Yard Packaging <packaging@engineyard.com>  ${DATE}
EOF

	# Extension INI
	cat - > "${CWD}/${PHP_VERSION}${EXTENSION_CONFIG}ioncube-loader.ini" <<EOF
; priority=01
zend_extension=ioncube_loader_lin_${PHP_VERSION}.so
EOF

	# Copyright
	gzip -9 > "${CWD}/${PHP_VERSION}/usr/share/doc/ioncube-loader/copyright.Debian.gz"<<EOF
This package was debianized by Engine Yard Packaging <packaging@engineyard.com>
on ${DATE}.

It was downloaded from http://www.ioncube.com/loaders.php

Upstream Author(s):

    ionCube Software LLP

Copyright:

    Copyright (C) 2002-${YEAR} ionCube Software LLP.

License:

    http://www.ioncube.com/tnc.php

The Debian packaging is copyright ${YEAR}, Engine Yard Packaging <packaging@engineyard.com> and
is licensed under the GPL, see '/usr/share/common-licenses/GPL'.

EOF

}
done

exit 0
