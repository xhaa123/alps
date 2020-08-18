#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf


cd $SOURCE_DIR

NAME=gpm
VERSION=1.20.7
URL=http://anduin.linuxfromscratch.org/BLFS/gpm/gpm-1.20.7.tar.bz2
SECTION="System Utilities"
DESCRIPTION="The GPM (General Purpose Mouse daemon) package contains a mouse server for the console and xterm. It not only provides cut and paste support generally, but its library component is used by various software such as Links to provide mouse support to the application. It is useful on desktops, especially if following (Beyond) Linux From Scratch instructions; it's often much easier (and less error prone) to cut and paste between two console windows than to type everything by hand!"

wget -nc $URL
wget -nc http://www.linuxfromscratch.org/patches/blfs/svn/gpm-1.20.7-consolidated-1.patch

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

patch -Np1 -i ../gpm-1.20.7-consolidated-1.patch &&
./autogen.sh                                     &&
./configure --prefix=/usr --sysconfdir=/etc      &&
make

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make install                                          &&

install-info --dir-file=/usr/share/info/dir           \
             /usr/share/info/gpm.info                 &&

ln -sfv libgpm.so.2.1.0 /usr/lib/libgpm.so            &&
install -v -m644 conf/gpm-root.conf /etc              &&

install -v -m755 -d /usr/share/doc/gpm-1.20.7/support &&
install -v -m644    doc/support/*                     \
                    /usr/share/doc/gpm-1.20.7/support &&
install -v -m644    doc/{FAQ,HACK_GPM,README*}        \
                    /usr/share/doc/gpm-1.20.7
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
make install-gpm
popd
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
install -v -dm755 /etc/systemd/system/gpm.service.d &&
cat > /etc/systemd/system/gpm.service.d/99-user.conf << EOF
[Service]
ExecStart=/usr/sbin/gpm <list of parameters>
EOF
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
