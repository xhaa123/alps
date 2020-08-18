#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

cd $SOURCE_DIR

NAME=wqy-zenhei
VERSION=0.9.45
URL=https://nchc.dl.sourceforge.net/project/wqy/wqy-zenhei/0.9.45%20%28Fighting-state%20RC1%29/wqy-zenhei-0.9.45.tar.gz
SECTION="Others"
DESCRIPTION="This project aims to develop the most complete, standard compliant, high-quality Chinese (and CJKV) fonts and resources, including bitmap and outline fonts of various styles. We also develop web-based tools to facilitate online font-dev collaborations."

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
mkdir -pv /usr/share/fonts/wenquanyi/wqy-zenhei/
mkdir -pv /etc/fonts/conf.avail/
mkdir -pv /etc/fonts/conf.d 
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
install -m644 *.ttc /usr/share/fonts/wenquanyi/wqy-zenhei/
install -m644 *.conf /etc/fonts/conf.avail/
install -m755 -D zenheiset /usr/bin/zenheiset
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
mv /etc/fonts/conf.avail/44-wqy-zenhei.conf /etc/fonts/conf.avail/65-wqy-zenhei.conf
cd /etc/fonts/conf.d/
ln -s ../conf.avail/65-wqy-zenhei.conf .
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

