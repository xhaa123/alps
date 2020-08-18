#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:efibootmgr
#REQ:dejavu-fonts

cd $SOURCE_DIR

NAME=grub-efi
VERSION=2.04
URL=https://ftp.gnu.org/gnu/grub/grub-2.04.tar.xz
SECTION="Others"
DESCRIPTION="GNU GRand Unified Bootloader (2)"

wget -nc $URL
wget -nc http://unifoundry.com/pub/unifont/unifont-13.0.03/font-builds/unifont-13.0.03.pcf.gz

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
mkdir -pv /usr/share/fonts/unifont &&
gunzip -c ../unifont-13.0.03.pcf.gz > \
     /usr/share/fonts/unifont/unifont.pcf
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

./configure --prefix=/usr            \
    --sbindir=/sbin                  \
    --sysconfdir=/etc                \
    --disable-efiemu                 \
    --enable-grub-mkfont             \
    --with-platform=efi              \
    --enable-boot-time               \
    --enable-device-mapper           \
    --target=x86_64                  \
    --enable-cache-stats             \
    --enable-mm-debug                \
    --enable-nls                     \
    --prefix="/usr"                  \
    --bindir="/usr/bin"              \
    --mandir="/usr/share/man"        \
    --infodir="/usr/share/info"      \
    --datarootdir="/usr/share"       \
    --program-prefix=""              \
    --with-bootdir="/boot"           \
    --with-grubdir="grub"            \
    --disable-silent-rules           \
    --disable-werror 
make

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make install
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
