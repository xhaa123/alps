#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:xcursor-themes


cd $SOURCE_DIR

NAME=x7font
VERSION=1
SECTION="X Window System Environment"
DESCRIPTION="The Xorg font packages provide some scalable fonts and supporting packages for Xorg applications. Many people will want to install other TTF or OTF fonts in addition to, or instead of, these. Some are listed at the section called “TTF and OTF fonts”."



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

cat > font-7.md5 << "EOF"
3d6adb76fdd072db8c8fae41b40855e8  font-util-1.3.2.tar.bz2
bbae4f247b88ccde0e85ed6a403da22a  encodings-1.0.5.tar.bz2
0497de0176a0dfa5fac2b0552a4cf380  font-alias-1.0.4.tar.bz2
fcf24554c348df3c689b91596d7f9971  font-adobe-utopia-type1-1.0.4.tar.bz2
e8ca58ea0d3726b94fe9f2c17344be60  font-bh-ttf-1.0.3.tar.bz2
53ed9a42388b7ebb689bdfc374f96a22  font-bh-type1-1.0.3.tar.bz2
bfb2593d2102585f45daa960f43cb3c4  font-ibm-type1-1.0.3.tar.bz2
4ee18ab6c1edf636b8e75b73e6037371  font-misc-ethiopic-1.0.4.tar.bz2
3eeb3fb44690b477d510bbd8f86cf5aa  font-xfree86-type1-1.0.4.tar.bz2
EOF

mkdir -p font &&
cd font &&
grep -v '^#' ../font-7.md5 | awk '{print $2}' | wget -i- -nc \
    -B https://www.x.org/pub/individual/font/ &&
md5sum -c ../font-7.md5 &&


for package in $(grep -v '^#' ../font-7.md5 | awk '{print $2}')
do
  packagedir=${package%.tar.bz2}
  tar -xf $package
  pushd $packagedir
    ./configure $XORG_CONFIG
    make
    
    rm -rf /tmp/rootscript.sh
    cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
make install
ENDOFROOTSCRIPT

    chmod a+x /tmp/rootscript.sh
    /tmp/rootscript.sh
    rm -rf /tmp/rootscript.sh

  popd

  rm -rf /tmp/rootscript.sh
  cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
rm -rf $packagedir
ENDOFROOTSCRIPT

  chmod a+x /tmp/rootscript.sh
  /tmp/rootscript.sh
  rm -rf /tmp/rootscript.sh
done

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
install -v -d -m755 /usr/share/fonts                               &&
ln -svfn $XORG_PREFIX/share/fonts/X11/OTF /usr/share/fonts/X11-OTF &&
ln -svfn $XORG_PREFIX/share/fonts/X11/TTF /usr/share/fonts/X11-TTF
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"
