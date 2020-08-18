#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:qt5

cd $SOURCE_DIR

NAME=noto-fonts
VERSION=1

SECTION="X Window System Environment"
DESCRIPTION="The presence or absence of the which program in the main LFS book is probably one of the most contentious issues on the mailing lists. It has resulted in at least one flame war in the past. To hopefully put an end to this once and for all, presented here are two options for equipping your system with which. The question of which “which” is for you to decide."

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

mkdir -pv noto-fonts 
cd noto-fonts

wget -nc https://noto-website-2.storage.googleapis.com/pkgs/NotoSans-hinted.zip
wget -nc https://noto-website-2.storage.googleapis.com/pkgs/NotoSerif-hinted.zip
wget -nc https://noto-website-2.storage.googleapis.com/pkgs/NotoSansDisplay-hinted.zip
wget -nc https://noto-website-2.storage.googleapis.com/pkgs/NotoSerifDisplay-hinted.zip
wget -nc https://noto-website-2.storage.googleapis.com/pkgs/NotoMono-hinted.zip
wget -nc https://noto-website-2.storage.googleapis.com/pkgs/NotoColorEmoji-unhinted.zip
wget -nc https://noto-website-2.storage.googleapis.com/pkgs/NotoEmoji-unhinted.zip

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
mkdir -pv /usr/share/fonts/truetype/noto-fonts
find . -name "*zip" -exec unzip -o {} -d /usr/share/fonts/truetype/noto-fonts \;
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh


if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
