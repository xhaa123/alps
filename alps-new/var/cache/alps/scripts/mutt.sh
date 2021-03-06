#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:lynx
#REQ:links


cd $SOURCE_DIR

NAME=mutt
VERSION=1.14.6
URL=https://bitbucket.org/mutt/mutt/downloads/mutt-1.14.6.tar.gz
SECTION="Mail/News Clients"
DESCRIPTION="The Mutt package contains a Mail User Agent. This is useful for reading, writing, replying to, saving, and deleting your email."

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
groupadd -g 34 mail
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
chgrp -v mail /var/mail
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

sed -i -e 's/ -with_backspaces//' -e 's/elinks/links/' \
  -e 's/-no-numbering -no-references//' doc/Makefile.in

./configure --prefix=/usr                            \
            --sysconfdir=/etc                        \
            --with-docdir=/usr/share/doc/mutt-1.14.6 \
            --with-ssl                               \
            --enable-external-dotlock                \
            --enable-pop                             \
            --enable-imap                            \
            --enable-hcache                          \
            --enable-sidebar                         &&
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
chown root:mail /usr/bin/mutt_dotlock &&
chmod -v 2755 /usr/bin/mutt_dotlock
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
cat /usr/share/doc/mutt-1.14.6/samples/gpg.rc >> ~/.muttrc
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
