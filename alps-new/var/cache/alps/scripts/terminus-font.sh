#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:fontconfig


cd $SOURCE_DIR

NAME=terminus-font
VERSION=4.48
URL=https://sources.voidlinux.org/terminus-font-4.48/terminus-font-4.48.tar.gz
SECTION="X Window System Environment"
DESCRIPTION="Terminus Font (clean, fixed width bitmap font for linux console)"

wget -nc $URL

if [ ! -z $URL ]; then

	TARBALL=$(echo $URL | rev | cut -d/ -f1 | rev)
	if [ -z $(echo $TARBALL | grep ".zip$") ]; then
		DIRECTORY=$(tar tf $TARBALL | cut -d/ -f1 | uniq | grep -v "^\.$")
		rm -rf $DIRECTORY
		tar --no-overwrite-dir -xf $TARBALL
	else
		DIRECTORY=$(unzip_dirname $TARBALL $NAME)
		unzip_file $TARBALL $NAME
	fi

	cd $DIRECTORY
fi

echo $USER > /tmp/currentuser

./configure --prefix=/usr
make psf

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make install-psf
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
cat > /etc/vconsole.conf << "EOF"
KEYMAP=us
FONT=ter-32n
EOF
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

