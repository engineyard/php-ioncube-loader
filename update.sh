#!/bin/sh

set -e nounset
set -e errexit

DATE="$(date +"%a, %d %b %Y %T %z")"
YEAR="$(date +"%Y")"

TARBALL="ioncube_loaders_lin_x86-64.tar.gz"
IONCUBE_URL="http://downloads3.ioncube.com/loader_downloads/$TARBALL"

errexit() {
	echo "$1"
	exit 1
}

if [ ! -d debian ]; then
	errexit "Run from root of packaging directory."
fi

CWD=$(pwd)

# Check available commands
for cmd in curl
do
	command -v $cmd > /dev/null || errexit "$cmd required."
done

read -p "ionCube version: " VERSION
if [ -z $VERSION ]; then
	errexit "Version must be specified."
fi

read -p "Ubuntu series: " UBUNTU_SERIES
if [ -z $UBUNTU_SERIES ]; then
	errexit "Ubuntu series must be specified."
fi
case $UBUNTU_SERIES in
	precise)
		UBUNTU_VERSION="12.04"
	;;
	trusty)
		UBUNTU_VERSION="14.04"
	;;
	*)
		errexit "Unsupported series '$UBUNTU_SERIES' - should be one of: precise, trusty"
esac

if [ ! -f $TARBALL ]; then
	curl -s -L $IONCUBE_URL -o $TARBALL
fi

tar -xzvf $TARBALL

# Changelog
cat - > debian/changelog <<EOF
php-ioncube-loader (${VERSION}-1~ubuntu${UBUNTU_VERSION}) $UBUNTU_SERIES; urgency=low

  * Upstream release.

 -- Engine Yard Packaging <packaging@engineyard.com>  ${DATE}
EOF

# Copyright
cat - > debian/copyright <<EOF
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

exit 0
