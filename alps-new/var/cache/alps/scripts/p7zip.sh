#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf



cd $SOURCE_DIR

NAME=p7zip
VERSION=16.02
URL=https://downloads.sourceforge.net/p7zip/p7zip_16.02_src_all.tar.bz2
SECTION="System Utilities"
DESCRIPTION="p7zip is the Unix command-line port of 7-Zip, a file archiver that archives with high compression ratios. It handles 7z, ZIP, GZIP, BZIP2, XZ, TAR, APM, ARJ, CAB, CHM, CPIO, CramFS, DEB, DMG, FAT, HFS, ISO, LZH, LZMA, LZMA2, MBR, MSI, MSLZ, NSIS, NTFS, RAR RPM, SquashFS, UDF, VHD, WIM, XAR and Z formats."

wget -nc $URL
wget -nc http://www.linuxfromscratch.org/patches/blfs/svn/p7zip-16.02-consolidated_fixes-1.patch

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

patch -Np1 -i ../p7zip-16.02-consolidated_fixes-1.patch

make all3

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make DEST_HOME=/usr \
     DEST_MAN=/usr/share/man \
     DEST_SHARE_DOC=/usr/share/doc/p7zip-16.02 install
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
