#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:autoconf213
#REQ:cbindgen
#REQ:gtk3
#REQ:gtk2
#REQ:llvm
#REQ:nodejs
#REQ:pulseaudio
#REQ:alsa-lib
#REQ:python3
#REQ:startup-notification
#REQ:zip
#REQ:unzip
#REQ:yasm
#REQ:icu
#REQ:libevent
#REQ:nspr
#REQ:nss


cd $SOURCE_DIR

NAME=thunderbird
VERSION=78.1.0
URL=https://archive.mozilla.org/pub/thunderbird/releases/78.1.0/source/thunderbird-78.1.0.source.tar.xz
SECTION="Other X-based Programs"
DESCRIPTION="Thunderbird is a stand-alone mail/news client based on the Mozilla codebase. It uses the Gecko rendering engine to enable it to display and compose HTML emails."

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

if ! grep -ri "/opt/rustc/lib" /etc/ld.so.conf &> /dev/null; then
    echo "/opt/rustc/lib" | sudo tee -a /etc/ld.so.conf
    sudo ldconfig
fi

ldconfig
. /etc/profile.d/rustc.sh

cat > mozconfig << "EOF"
# If you have a multicore machine, all cores will be used.

# If you have installed wireless-tools comment out this line:
ac_add_options --disable-necko-wifi

# Uncomment the following option if you have not installed PulseAudio
#ac_add_options --disable-pulseaudio
# and uncomment this if you installed alsa-lib instead of PulseAudio
#ac_add_options --enable-alsa

# If you want to compile the Mozilla Calendar, uncomment this line:
#ac_add_options --enable-calendar

# Comment out following options if you have not installed
# recommended dependencies:
ac_add_options --with-system-libevent
ac_add_options --with-system-nspr
ac_add_options --with-system-nss
ac_add_options --with-system-icu

# The elf-hack causes failed builds on clang-9.0.1 with some CFLAGS including
# -march=native on Ryzen. It is supposed to improve startup time and it shrinks
# libxul.so by a few MB - Uncomment this if your build is affected.
#ac_add_options --disable-elf-hack

# The BLFS editors recommend not changing anything below this line:
ac_add_options --prefix=/usr
ac_add_options --enable-application=comm/mail

ac_add_options --disable-crashreporter
ac_add_options --disable-updater
ac_add_options --disable-debug
ac_add_options --disable-tests

ac_add_options --enable-optimize=-O2
ac_add_options --enable-strip
ac_add_options --enable-install-strip

ac_add_options --enable-official-branding

ac_add_options --enable-system-ffi
ac_add_options --enable-system-pixman

ac_add_options --with-system-jpeg
ac_add_options --with-system-png
ac_add_options --with-system-zlib
EOF

./mach build

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
./mach install
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
mkdir -pv /usr/share/{applications,pixmaps} &&

cat > /usr/share/applications/thunderbird.desktop << "EOF" &&
[Desktop Entry]
Name=Thunderbird Mail
Comment=Send and receive mail with Thunderbird
GenericName=Mail Client
Exec=thunderbird %u
Terminal=false
Type=Application
Icon=thunderbird
Categories=Network;Email;
MimeType=application/xhtml+xml;text/xml;application/xhtml+xml;application/xml;application/rss+xml;x-scheme-handler/mailto;
StartupNotify=true
EOF

ln -sfv /usr/lib/thunderbird/chrome/icons/default/default256.png \
        /usr/share/pixmaps/thunderbird.png
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh


if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
