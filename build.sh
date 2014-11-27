#!/bin/sh

set -o nounset
set -o errexit

DEBFULLNAME=${DEBFULLNAME:-"Engine Yard Packaging"}
DEBEMAIL=${DEBEMAIL:-"packaging@engineyard.com"}

DATE="$(date +"%a, %d %b %Y %T %z")"
YEAR="$(date +"%Y")"
PACKAGING_VERSION=6

TARBALL="ioncube_loaders_lin_x86-64.tar.gz"
IONCUBE_URL="http://downloads3.ioncube.com/loader_downloads/$TARBALL"

output(){
	printf "$1\n"
}

except() {
	output "$1"
	exit 1
}

CWD=$(pwd)

download() {
	printf "Downloading...\n"
	if command -v curl >/dev/null; then
		curl -s -L $IONCUBE_URL -o $TARBALL
	elif command -v wget >/dev/null; then
		wget -O $TARBALL $IONCUBE_URL
	else
		except "Needs curl or wget."
	fi
}

if [ ! -d debian ]; then
	except "Run from root of packaging directory."
fi

if [ "$#" != "0" ]; then
	if [ "$1" = "download" ]; then
		download
		exit 0
	fi
fi
if [ ! -f $TARBALL ]; then
	except "No tarball found ($TARBALL) - run ./$(basename $0) download"
else
	output "Extrating tarball..."
	tar -xzvf $TARBALL >/dev/null 2>&1
fi

read -p "ionCube version: " VERSION
if [ -z $VERSION ]; then
	except "Version must be specified."
fi

read -p "Ubuntu series (precise, trusty): " UBUNTU_SERIES
if [ -z $UBUNTU_SERIES ]; then
	except "Ubuntu series must be specified."
fi
case $UBUNTU_SERIES in
	precise)
		UBUNTU_VERSION="12.04"
	;;
	trusty)
		UBUNTU_VERSION="14.04"
	;;
	*)
		except "Unsupported series '$UBUNTU_SERIES'"
esac

# Changelog
cat - > debian/changelog <<EOF
php-ioncube-loader (${VERSION}-${PACKAGING_VERSION}~ubuntu${UBUNTU_VERSION}) $UBUNTU_SERIES; urgency=low

  * Upstream release.

 -- ${DEBFULLNAME} <${DEBEMAIL}>  ${DATE}
EOF

# Copyright
cat - > debian/copyright <<EOF
This package was debianized by ${DEBFULLNAME} <${DEBEMAIL}>
on ${DATE}.

It was downloaded from http://www.ioncube.com/loaders.php

Upstream Author(s):

    ionCube Software LLP

Copyright:

    Copyright (C) 2002-${YEAR} ionCube Software LLP.

License:

    http://www.ioncube.com/tnc.php

The Debian packaging is copyright ${YEAR}, ${DEBFULLNAME} <${DEBEMAIL}> and
is licensed under the GPL, see '/usr/share/common-licenses/GPL'.

EOF

exit 0
