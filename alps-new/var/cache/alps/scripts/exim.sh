#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:libnsl
#REQ:pcre


cd $SOURCE_DIR

NAME=exim
VERSION=4.94
URL=https://ftp.exim.org/pub/exim/exim4/exim-4.94.tar.xz
SECTION="Mail Server Software"
DESCRIPTION="The Exim package contains a Mail Transport Agent written by the University of Cambridge, released under the GNU Public License."

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
groupadd -g 31 exim &&
useradd -d /dev/null -c "Exim Daemon" -g exim -s /bin/false -u 31 exim
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

sed -e 's,^BIN_DIR.*$,BIN_DIRECTORY=/usr/sbin,'    \
    -e 's,^CONF.*$,CONFIGURE_FILE=/etc/exim.conf,' \
    -e 's,^EXIM_USER.*$,EXIM_USER=exim,'           \
    -e '/# SUPPORT_TLS=yes/s,^#,,'                   \
    -e '/# USE_OPENSSL/s,^#,,'                       \
    -e 's,^EXIM_MONITOR,#EXIM_MONITOR,' src/EDITME > Local/Makefile &&

printf "USE_GDBM = yes\nDBMLIB = -lgdbm\n" >> Local/Makefile &&
make

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make install                                    &&
install -v -m644 doc/exim.8 /usr/share/man/man8 &&

install -v -d -m755    /usr/share/doc/exim-4.94 &&
install -v -m644 doc/* /usr/share/doc/exim-4.94 &&

ln -sfv exim /usr/sbin/sendmail                 &&
install -v -d -m750 -o exim -g exim /var/spool/exim
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh


rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
chmod -v a+wt /var/mail
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
cat >> /etc/aliases << "EOF"
postmaster: root
MAILER-DAEMON: root
EOF
exim -v -bi &&
/usr/sbin/exim -bd -q15m
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
#!/bin/bash

set -e
set +h


. ~/.bashrc
. /etc/alps/alps.conf

pushd $SOURCE_DIR
wget -nc http://www.linuxfromscratch.org/blfs/downloads/systemd/blfs-systemd-units-20200415.tar.xz
tar xf blfs-systemd-units-20200415.tar.xz
cd blfs-systemd-units-20200415
make install-exim
popd
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
