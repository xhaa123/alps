#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf



cd $SOURCE_DIR

NAME=mailx
VERSION=12.5
URL=http://ftp.debian.org/debian/pool/main/h/heirloom-mailx/heirloom-mailx_12.5.orig.tar.gz
SECTION="Mail/News Clients"
DESCRIPTION="The Heirloom mailx package (formerly known as the Nail package) contains mailx, a command-line Mail User Agent derived from Berkeley Mail. It is intended to provide the functionality of the POSIX mailx command with additional support for MIME messages, IMAP (including caching), POP3, SMTP, S/MIME, message threading/sorting, scoring, and filtering. Heirloom mailx is especially useful for writing scripts and batch processing."

wget -nc $URL
wget -nc http://www.linuxfromscratch.org/patches/blfs/svn/heirloom-mailx-12.5-fixes-1.patch

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

patch -Np1 -i ../heirloom-mailx-12.5-fixes-1.patch &&

sed 's@<openssl@<openssl-1.0/openssl@' \
    -i openssl.c fio.c makeconfig      &&

make -j1 LDFLAGS+="-L /usr/lib/openssl-1.0/" \
     SENDMAIL=/usr/sbin/sendmail

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make PREFIX=/usr UCBINSTALL=/usr/bin/install install &&

ln -v -sf mailx /usr/bin/mail &&
ln -v -sf mailx /usr/bin/nail &&

install -v -m755 -d     /usr/share/doc/heirloom-mailx-12.5 &&
install -v -m644 README /usr/share/doc/heirloom-mailx-12.5
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
