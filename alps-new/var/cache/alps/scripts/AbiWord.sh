#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:boost
#REQ:fribidi
#REQ:goffice010
#REQ:wv
#REQ:enchant


cd $SOURCE_DIR

NAME=AbiWord
VERSION=3.0.4
URL=http://www.abisource.com/downloads/abiword/3.0.4/source/abiword-3.0.4.tar.gz
SECTION="Office Programs"
DESCRIPTION="AbiWord is a word processor which is useful for writing reports, letters and other formatted documents."

wget -nc $URL
wget -nc http://www.abisource.com/downloads/abiword/3.0.2/source/abiword-docs-3.0.2.tar.gz


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

sed -e "s/free_suggestions/free_string_list/" \
    -e "s/_to_personal//"                     \
    -e "s/in_session/added/"                  \
    -i src/af/xap/xp/enchant_checker.cpp      &&

./configure --prefix=/usr &&
make

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make install
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

tar -xf ../abiword-docs-3.0.2.tar.gz &&
cd abiword-docs-3.0.1                &&
./configure --prefix=/usr            &&
make

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make install
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
ls /usr/share/abiword-3.0/templates
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
install -v -m750 -d ~/.AbiSuite/templates &&
install -v -m640    /usr/share/abiword-3.0/templates/normal.awt-<lang> \
                    ~/.AbiSuite/templates/normal.awt
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
