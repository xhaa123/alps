#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:perl-modules#perl-archive-zip
#REQ:unzip
#REQ:wget
#REQ:which
#REQ:zip
#REQ:apache-ant
#REQ:apr
#REQ:boost
#REQ:clucene
#REQ:cups
#REQ:curl
#REQ:dbus-glib
#REQ:libepoxy
#REQ:libjpeg
#REQ:glm
#REQ:glu
#REQ:gpgme
#REQ:graphite2
#REQ:gst10-plugins-base
#REQ:gtk3
#REQ:harfbuzz
#REQ:libatomic_ops
#REQ:lcms2
#REQ:librsvg
#REQ:libxml2
#REQ:libxslt
#REQ:python-modules#lxml
#REQ:mesa
#REQ:neon
#REQ:nss
#REQ:openldap
#REQ:poppler
#REQ:postgresql
#REQ:redland
#REQ:serf
#REQ:unixodbc
#REQ:desktop-file-utils


cd $SOURCE_DIR

NAME=libreoffice
VERSION=6.4.5
URL=http://download.documentfoundation.org/libreoffice/src/6.4.5/libreoffice-6.4.5.2.tar.xz
SECTION="Office Programs"
DESCRIPTION="LibreOffice is a full-featured office suite. It is largely compatible with Microsoft Office and is descended from OpenOffice.org."

wget -nc $URL
wget -nc http://download.documentfoundation.org/libreoffice/src/6.4.5/libreoffice-dictionaries-6.4.5.2.tar.xz
wget -nc http://download.documentfoundation.org/libreoffice/src/6.4.5/libreoffice-help-6.4.5.2.tar.xz
wget -nc http://download.documentfoundation.org/libreoffice/src/6.4.5/libreoffice-translations-6.4.5.2.tar.xz
wget -nc http://www.linuxfromscratch.org/patches/blfs/svn/libreoffice-6.4.5.2-format_overflow-1.patch


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

tar -xf libreoffice-6.4.5.2.tar.xz --no-overwrite-dir &&
cd libreoffice-6.4.5.2

patch -Np1 -i ../libreoffice-6.4.5.2-format_overflow-1.patch

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
install -dm755 external/tarballs &&
ln -sv ../../../libreoffice-dictionaries-6.4.5.2.tar.xz external/tarballs/ &&
ln -sv ../../../libreoffice-help-6.4.5.2.tar.xz         external/tarballs/ &&
ln -sv ../../../libreoffice-translations-6.4.5.2.tar.xz external/tarballs/
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

export LO_PREFIX=/opt

sed -e "/gzip -f/d"   \
    -e "s|.1.gz|.1|g" \
    -i bin/distro-install-desktop-integration &&

sed -e "/distro-install-file-lists/d" -i Makefile.in &&

sed -e 's@getURI()->c_str()@getURI().c_str()@' \
    -i sdext/source/pdfimport/xpdfwrapper/pdfioutdev_gpl.cxx &&

./autogen.sh --prefix=$LO_PREFIX         \
             --sysconfdir=/etc           \
             --with-vendor=BLFS          \
             --with-lang='fr en-GB'      \
             --with-help                 \
             --with-myspell-dicts        \
             --without-junit             \
             --without-system-dicts      \
             --disable-dconf             \
             --disable-odk               \
             --enable-release-build=yes  \
             --enable-python=system      \
             --with-jdk-home=/opt/jdk    \
             --with-system-apr           \
             --with-system-boost         \
             --with-system-clucene       \
             --with-system-curl          \
             --with-system-epoxy         \
             --with-system-expat         \
             --with-system-glm           \
             --with-system-gpgmepp       \
             --with-system-graphite      \
             --with-system-harfbuzz      \
             --with-system-icu           \
             --with-system-jpeg          \
             --with-system-lcms2         \
             --with-system-libatomic_ops \
             --with-system-libpng        \
             --with-system-libxml        \
             --with-system-neon          \
             --with-system-nss           \
             --with-system-odbc          \
             --with-system-openldap      \
             --with-system-openssl       \
             --with-system-poppler       \
             --with-system-postgresql    \
             --with-system-redland       \
             --with-system-serf          \
             --with-system-zlib

make build-nocheck

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make distro-pack-install
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
if [ "$LO_PREFIX" != "/usr" ]; then

  # This symlink is necessary for the desktop menu entries
  ln -svf $LO_PREFIX/lib/libreoffice/program/soffice /usr/bin/libreoffice &&

  # Set up a generic location independent of version number
  ln -sfv libreoffice-6.4.5.2 /opt/libreoffice 

  # Icons
  mkdir -vp /usr/share/pixmaps
  for i in $LO_PREFIX/share/icons/hicolor/32x32/apps/*; do
    ln -svf $i /usr/share/pixmaps
  done &&

  # Desktop menu entries
  for i in $LO_PREFIX/lib/libreoffice/share/xdg/*; do
    ln -svf $i /usr/share/applications/libreoffice-$(basename $i)
  done &&

  # Man pages
  for i in $LO_PREFIX/share/man/man1/*; do
    ln -svf $i /usr/share/man/man1/
  done

  unset i
fi
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
update-desktop-database
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
