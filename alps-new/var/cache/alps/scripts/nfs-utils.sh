#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:libtirpc
#REQ:rpcsvc-proto


cd $SOURCE_DIR

NAME=nfs-utils
VERSION=2.5.1
URL=https://www.kernel.org/pub/linux/utils/nfs-utils/2.5.1/nfs-utils-2.5.1.tar.xz
SECTION="Networking Programs"
DESCRIPTION="The NFS Utilities package contains the userspace server and client tools necessary to use the kernel's NFS abilities. NFS is a protocol that allows sharing file systems over the network."

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
groupadd -g 99 nogroup &&
useradd -c "Unprivileged Nobody" -d /dev/null -g nogroup \
    -s /bin/false -u 99 nobody
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

./configure --prefix=/usr          \
            --sysconfdir=/etc      \
            --sbindir=/sbin        \
            --disable-nfsv4        \
            --disable-gss &&
make

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make install                      &&
mv -v /sbin/start-statd /usr/sbin &&
chmod u+w,go+r /sbin/mount.nfs    &&
chown nobody.nogroup /var/lib/nfs
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
cat >> /etc/exports << EOF
/home 192.168.0.0/24(rw,subtree_check,anonuid=99,anongid=99)
EOF
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
make install-nfsv4-server
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
make install-nfs-server
popd
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

<server-name>:/home  /home nfs   rw,_netdev 0 0
<server-name>:/usr   /usr  nfs   ro,_netdev 0 0

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
make install-nfs-client
popd
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
