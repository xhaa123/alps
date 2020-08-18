#!/bin/bash

set -e
set +h

. /etc/alps/alps.conf
. /var/lib/alps/functions
. /etc/alps/directories.conf

#REQ:cmake
#REQ:python-modules#sphinx
#REQ:python-modules#recommonmark



cd $SOURCE_DIR

NAME=llvm
VERSION=10.0.1
URL=https://github.com/llvm/llvm-project/releases/download/llvmorg-10.0.1/llvm-10.0.1.src.tar.xz
SECTION="Programming"
DESCRIPTION='The LLVM package contains a collection of modular and reusable compiler and toolchain technologies. The Low Level Virtual Machine (LLVM) Core libraries provide a modern source and target-independent optimizer, along with code generation support for many popular CPUs (as well as some less common ones!). These libraries are built around a well specified code representation known as the LLVM intermediate representation ("LLVM IR").'

wget -nc $URL
wget -nc https://github.com/llvm/llvm-project/releases/download/llvmorg-10.0.1/clang-10.0.1.src.tar.xz
wget -nc https://github.com/llvm/llvm-project/releases/download/llvmorg-10.0.1/compiler-rt-10.0.1.src.tar.xz

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

tar -xf ../clang-10.0.1.src.tar.xz -C tools          &&
tar -xf ../compiler-rt-10.0.1.src.tar.xz -C projects &&

mv tools/clang-10.0.1.src tools/clang &&
mv projects/compiler-rt-10.0.1.src projects/compiler-rt

mkdir -v build &&
cd       build &&

CC=gcc CXX=g++                                  \
cmake -DCMAKE_INSTALL_PREFIX=/usr               \
      -DLLVM_ENABLE_FFI=ON                      \
      -DCMAKE_BUILD_TYPE=Release                \
      -DLLVM_BUILD_LLVM_DYLIB=ON                \
      -DLLVM_LINK_LLVM_DYLIB=ON                 \
      -DLLVM_ENABLE_RTTI=ON                     \
      -DLLVM_TARGETS_TO_BUILD="host;AMDGPU;BPF" \
      -DLLVM_BUILD_TESTS=ON                     \
      -Wno-dev -G Ninja ..                      &&
ninja

cmake -DLLVM_ENABLE_SPHINX=ON         \
      -DSPHINX_WARNINGS_AS_ERRORS=OFF \
      -Wno-dev -G Ninja ..            &&
ninja docs-llvm-html  docs-llvm-man

ninja docs-clang-html docs-clang-man

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
ninja install
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
install -v -m644 docs/man/* /usr/share/man/man1             &&
install -v -d -m755 /usr/share/doc/llvm-10.0.1/llvm-html     &&
cp -Rv docs/html/* /usr/share/doc/llvm-10.0.1/llvm-html
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

rm -rf /tmp/rootscript.sh
cat > /tmp/rootscript.sh <<"ENDOFROOTSCRIPT"
install -v -m644 tools/clang/docs/man/* /usr/share/man/man1 &&
install -v -d -m755 /usr/share/doc/llvm-10.0.1/clang-html    &&
cp -Rv tools/clang/docs/html/* /usr/share/doc/llvm-10.0.1/clang-html
ENDOFROOTSCRIPT

chmod a+x /tmp/rootscript.sh
/tmp/rootscript.sh
rm -rf /tmp/rootscript.sh

if [ ! -z $URL ]; then cd $SOURCE_DIR && cleanup "$NAME" "$DIRECTORY"; fi

register_installed "$NAME" "$VERSION" "$INSTALLED_LIST"

 
