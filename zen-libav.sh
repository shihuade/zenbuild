#!/bin/bash

# Copyright (C) 2014 - Sebastien Alaiwan
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 3
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

source zen-ffmpeg_libav-common.sh

function build_libav {
  host=$1
  pushDir $WORK/src

  lazy_git_clone "git://git.libav.org/libav.git" libav a61c2115fb936d50b8b0328d00562fe529a7c46a

  local ARCH=$(get_arch $host)
  local OS=$(get_os $host)

  # remove stupid dependency
  sed -i "s/jack_jack_h pthreads/jack_jack_h/" libav/configure

  # remove GPL checking for x264
  sed -i 's/die_license_disabled gpl libx264/#die_license_disabled gpl libx264/' libav/configure

  mkdir -p libav/build/$host
  pushDir libav/build/$host
  ../../configure \
    --arch=$ARCH \
    --target-os=$OS \
    --prefix=$PREFIX/$host \
    --extra-cflags="-DWIN32=1 -I$PREFIX/$host/include" \
    --extra-ldflags="-L$PREFIX/$host/lib" \
    --disable-debug \
    --disable-static \
    --enable-shared \
    --enable-indev=jack \
    --enable-librtmp \
    --disable-gpl \
    --enable-libx264 \
    --disable-gnutls \
    --disable-openssl \
    --pkg-config=pkg-config \
    --cross-prefix=$host-
  $MAKE
  $MAKE install
  popDir

  popDir
}

function build_all {
  host=$1

  check_for_crosschain $host

  export PKG_CONFIG_PATH=$PREFIX/$host/lib/pkgconfig
  build $host x264
  build $host zlib
  build $host tre
  build $host libsndfile
  build $host jack
  build $host librtmp
  build $host libav
}

build_all x86_64-w64-mingw32
build_all i686-w64-mingw32

endBuild