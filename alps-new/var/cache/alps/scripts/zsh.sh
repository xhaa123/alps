#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf


cd $SOURCE_DIR

NAME=zsh
VERSION=5.8
URL=http://www.zsh.org/pub/zsh-5.8.tar.xz
SECTION="Shell"
DESCRIPTION="The zsh package contains a command interpreter (shell) usable as an interactive login shell and as a shell script command processor. Of the standard shells, zsh most closely resembles ksh but includes many enhancements."

wget -nc $URL
wget -nc http://www.zsh.org/pub/zsh-5.8-doc.tar.xz


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

tar --strip-components=1 -xvf ../zsh-5.8-doc.tar.xz

./configure --prefix=/usr         \
            --bindir=/bin         \
            --sysconfdir=/etc/zsh \
            --enable-etcdir=/etc/zsh                  &&
make                                                  &&

makeinfo  Doc/zsh.texi --plaintext -o Doc/zsh.txt     &&
makeinfo  Doc/zsh.texi --html      -o Doc/html        &&
makeinfo  Doc/zsh.texi --html --no-split --no-headers -o Doc/zsh.html

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make install                              &&
make infodir=/usr/share/info install.info &&

install -v -m755 -d                 /usr/share/doc/zsh-5.8/html &&
install -v -m644 Doc/html/*         /usr/share/doc/zsh-5.8/html &&
install -v -m644 Doc/zsh.{html,txt} /usr/share/doc/zsh-5.8
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make install                              &&
make infodir=/usr/share/info install.info &&

install -v -m755 -d                 /usr/share/doc/zsh-5.8/html &&
install -v -m644 Doc/html/*         /usr/share/doc/zsh-5.8/html &&
install -v -m644 Doc/zsh.{html,txt} /usr/share/doc/zsh-5.8
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make htmldir=/usr/share/doc/zsh-5.8/html install.html &&
install -v -m644 Doc/zsh.dvi /usr/share/doc/zsh-5.8
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
install -v -m644 Doc/zsh.pdf /usr/share/doc/zsh-5.8
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
mv -v /usr/lib/libpcre.so.* /lib &&
ln -v -sf ../../lib/libpcre.so.0 /usr/lib/libpcre.so

mv -v /usr/lib/libgdbm.so.* /lib &&
ln -v -sf ../../lib/libgdbm.so.3 /usr/lib/libgdbm.so
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
cat >> /etc/shells << "EOF"
/bin/zsh
EOF
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
