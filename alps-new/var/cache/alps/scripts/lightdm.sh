#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:exo
#REQ:libgcrypt
#REQ:itstool
#REQ:linux-pam
#REQ:pcre
#REQ:gobject-introspection
#REQ:libxklavier
#REQ:vala

cd $SOURCE_DIR

NAME=lightdm
VERSION=1.30.0
URL=https://github.com/CanonicalLtd/lightdm/releases/download/1.30.0/lightdm-1.30.0.tar.xz
SECTION="Display Managers"
DESCRIPTION="The lightdm package contains a lightweight display manager based upon GTK."

wget -nc $URL
wget -nc https://launchpad.net/lightdm-gtk-greeter/2.0/2.0.6/+download/lightdm-gtk-greeter-2.0.6.tar.gz


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
groupadd -g 65 lightdm       &&
useradd  -c "Lightdm Daemon" \
         -d /var/lib/lightdm \
         -u 65 -g lightdm    \
         -s /bin/false lightdm
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

./configure                          \
       --prefix=/usr                 \
       --libexecdir=/usr/lib/lightdm \
       --localstatedir=/var          \
       --sbindir=/usr/bin            \
       --sysconfdir=/etc             \
       --disable-static              \
       --disable-tests               \
       --with-greeter-user=lightdm   \
       --with-greeter-session=lightdm-gtk-greeter \
       --docdir=/usr/share/doc/lightdm-1.30.0 &&
make

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make install                                                  &&
cp tests/src/lightdm-session /usr/bin                         &&
sed -i '1 s/sh/bash --login/' /usr/bin/lightdm-session        &&
rm -rf /etc/init                                              &&
install -v -dm755 -o lightdm -g lightdm /var/lib/lightdm      &&
install -v -dm755 -o lightdm -g lightdm /var/lib/lightdm-data &&
install -v -dm755 -o lightdm -g lightdm /var/cache/lightdm    &&
install -v -dm770 -o lightdm -g lightdm /var/log/lightdm
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

tar -xf ../lightdm-gtk-greeter-2.0.6.tar.gz &&
cd lightdm-gtk-greeter-2.0.6 &&

./configure                      \
   --prefix=/usr                 \
   --libexecdir=/usr/lib/lightdm \
   --sbindir=/usr/bin            \
   --sysconfdir=/etc             \
   --with-libxklavier            \
   --enable-kill-on-sigterm      \
   --disable-libido              \
   --disable-libindicator        \
   --disable-static              \
   --docdir=/usr/share/doc/lightdm-gtk-greeter-2.0.6 &&

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
#!/bin/bash

set -e
set +h


. /etc/alps/alps.conf

pushd $SOURCE_DIR
  wget -nc http://www.linuxfromscratch.org/blfs/downloads/systemd/blfs-systemd-units-20200415.tar.xz
  tar xf blfs-systemd-units-20200415.tar.xz
  cd blfs-systemd-units-20200415
  make install-lightdm &&
  systemctl enable lightdm
popd
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
