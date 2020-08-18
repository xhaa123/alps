#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:gnutls
#REQ:jansson
#REQ:libtirpc
#REQ:lmdb
#REQ:rpcsvc-proto
#REQ:fuse
#REQ:gpgme
#REQ:libxslt
#REQ:linux-pam
#REQ:perl-modules#perl-parse-yapp
#REQ:python-modules#pycryptodome
#REQ:openldap


cd $SOURCE_DIR

NAME=samba
VERSION=4.12.5
URL=https://www.samba.org/ftp/samba/stable/samba-4.12.5.tar.gz
SECTION="Networking Programs"
DESCRIPTION="The Samba package provides file and print services to SMB/CIFS clients and Windows networking to Linux clients. Samba can also be configured as a Windows Domain Controller replacement, a file/print server acting as a member of a Windows Active Directory domain and a NetBIOS (rfc1001/1002) nameserver (which among other things provides LAN browsing support)."

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

echo "^samba4.rpc.echo.*on.*ncacn_np.*with.*object.*nt4_dc" >> selftest/knownfail

CFLAGS="-I/usr/include/tirpc"          \
LDFLAGS="-ltirpc"                      \
./configure                            \
    --prefix=/usr                      \
    --sysconfdir=/etc                  \
    --localstatedir=/var               \
    --with-piddir=/run/samba           \
    --with-pammodulesdir=/lib/security \
    --enable-fhs                       \
    --without-ad-dc                    \
    --enable-selftest                  &&
make

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make install &&

mv -v /usr/lib/libnss_win{s,bind}.so*   /lib                       &&
ln -v -sf ../../lib/libnss_winbind.so.2 /usr/lib/libnss_winbind.so &&
ln -v -sf ../../lib/libnss_wins.so.2    /usr/lib/libnss_wins.so    &&

install -v -m644    examples/smb.conf.default /etc/samba &&

mkdir -pv /etc/openldap/schema                        &&

install -v -m644    examples/LDAP/README              \
                    /etc/openldap/schema/README.LDAP  &&

install -v -m644    examples/LDAP/samba*              \
                    /etc/openldap/schema              &&

install -v -m755    examples/LDAP/{get*,ol*} \
                    /etc/openldap/schema
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
install -dvm 755 /usr/lib/cups/backend &&
ln -v -sf /usr/bin/smbspool /usr/lib/cups/backend/smb
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
make install-samba
popd
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
make install-winbindd
popd
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
