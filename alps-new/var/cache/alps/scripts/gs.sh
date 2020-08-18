#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:cups
#REQ:fontconfig
#REQ:freetype2
#REQ:libjpeg
#REQ:libpng
#REQ:libtiff
#REQ:lcms2
#REQ:openjpeg2

cd $SOURCE_DIR

NAME=gs
VERSION=9.52
URL=https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs952/ghostscript-9.52.tar.xz
SECTION="Printing"
DESCRIPTION="Ghostscript is a versatile processor for PostScript data with the ability to render PostScript to different targets. It is a mandatory part of the cups printing stack."

wget -nc $URL
wget -nc https://downloads.sourceforge.net/gs-fonts/ghostscript-fonts-std-8.11.tar.gz
wget -nc https://downloads.sourceforge.net/gs-fonts/gnu-gs-fonts-other-6.0.tar.gz


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

rm -rf freetype lcms2mt jpeg libpng openjpeg

rm -rf zlib &&

./configure --prefix=/usr           \
            --disable-compile-inits \
            --enable-dynamic        \
            --with-system-libtiff   &&
make

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make so
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make install
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make soinstall &&
install -v -m644 base/*.h /usr/include/ghostscript &&
ln -sfvn ghostscript /usr/include/ps
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
mv -v /usr/share/doc/ghostscript/9.52 /usr/share/doc/ghostscript-9.52  &&
rm -rfv /usr/share/doc/ghostscript &&
cp -r examples/ /usr/share/ghostscript/9.52/
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
tar -xvf ../ghostscript-fonts-std-8.11.tar.gz -C /usr/share/ghostscript --no-same-owner &&
tar -xvf ../gnu-gs-fonts-other-6.0.tar.gz     -C /usr/share/ghostscript --no-same-owner &&
fc-cache -v /usr/share/ghostscript/fonts/
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
gs -q -dBATCH /usr/share/ghostscript/9.52/examples/tiger.eps
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
