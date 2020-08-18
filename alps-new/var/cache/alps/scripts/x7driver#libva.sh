#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:libdrm
#REQ:mesa


cd $SOURCE_DIR

NAME=x7driver#libva
VERSION=2.8.0
URL=https://github.com/intel/libva/releases/download/2.8.0/libva-2.8.0.tar.bz2
SECTION="Xorg Drivers"
DESCRIPTION="The libva package contains a library which provides access to hardware accelerated video processing, using hardware to accelerate video processing in order to offload the central processing unit (CPU) to decode and encode compressed digital video. The VA API video decode/encode interface is platform and window system independent targeted at Direct Rendering Infrastructure (DRI) in the X Window System however it can potentially also be used with direct framebuffer and graphics sub-systems for video output. Accelerated processing includes support for video decoding, video encoding, subpicture blending, and rendering."

wget -nc $URL
wget -nc https://github.com/intel/intel-vaapi-driver/releases/download/2.4.1/intel-vaapi-driver-2.4.1.tar.bz2

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

export XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static"

./configure $XORG_CONFIG &&
make

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make install
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

tar -xvf ../intel-vaapi-driver-2.4.1.tar.bz2 &&
cd intel-vaapi-driver-2.4.1

./configure $XORG_CONFIG &&
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

 
