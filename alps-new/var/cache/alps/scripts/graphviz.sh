#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf




cd $SOURCE_DIR

NAME=graphviz
VERSION=2.44.1
URL=https://www2.graphviz.org/Packages/stable/portable_source/graphviz-2.44.1.tar.gz
SECTION="General Utilities"
DESCRIPTION="The Graphviz package contains graph visualization software. Graph visualization is a way of representing structural information as diagrams of abstract graphs and networks. Graphviz has several main graph layout programs. It also has web and interactive graphical interfaces, auxiliary tools, libraries, and language bindings."

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

sed -i '/LIBPOSTFIX="64"/s/64//' configure.ac &&

autoreconf                            &&
./configure --prefix=/usr PS2PDF=true &&
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
ln -v -s /usr/share/graphviz/doc /usr/share/doc/graphviz-2.44.1
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
