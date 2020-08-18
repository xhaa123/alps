#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:aspell
#REQ:enchant
#REQ:gmime
#REQ:gpgme
#REQ:gtk3
#REQ:rarian
#REQ:pcre
#REQ:compface
#REQ:libcanberra
#REQ:gcr
#REQ:openldap
#REQ:libsecret
#REQ:sqlite


cd $SOURCE_DIR

NAME=balsa
VERSION=2.5.11
URL=http://pawsa.fedorapeople.org/balsa/balsa-2.5.11.tar.bz2
SECTION="Other X-based Programs"
DESCRIPTION="The Balsa package contains a GNOME-2 based mail client."

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

./configure --prefix=/usr            \
            --sysconfdir=/etc        \
            --localstatedir=/var/lib \
            --without-html-widget    \
            --without-libnotify      \
            --with-canberra          \
            --with-compface          \
            --with-gcr               \
            --with-gss               \
            --with-ldap              \
            --with-libsecret         \
            --with-sqlite            &&
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

 
