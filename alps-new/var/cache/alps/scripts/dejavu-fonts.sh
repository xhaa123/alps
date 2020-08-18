#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:fontconfig


cd $SOURCE_DIR



NAME=dejavu-fonts
VERSION=2.37
URL=https://github.com/dejavu-fonts/dejavu-fonts/releases/download/version_2_37/dejavu-fonts-ttf-2.37.tar.bz2
SECTION="X Window System Environment"
DESCRIPTION="The DejaVu fonts are modifications of the Bitstream Vera fonts designed for greater coverage of Unicode, as well as providing more styles."

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

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
install -v -d -m755 /usr/share/fonts/dejavu &&
install -v -m644 ttf/*.ttf /usr/share/fonts/dejavu &&
fc-cache -v /usr/share/fonts/dejavu
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh


if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

