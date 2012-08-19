#!/bin/bash

if [ ! -x configure ]
then
  echo "Run this script from the GMP base directory"
  exit 1
fi

export NDK="${HOME}/Downloads/android-ndk-r8b"
if [ ! -d ${NDK} ]
then
  echo "Please download and install the NDK, then update the path in this script."
  echo "  http://developer.android.com/sdk/ndk/index.html"
  exit 1
fi

# Extract an android-9 toolchain if needed
export TARGET="android-9"
export TOOLCHAIN="/tmp/${TARGET}-x86"
if [ ! -d ${TOOLCHAIN} ]
then
  ${NDK}/build/tools/make-standalone-toolchain.sh --toolchain=x86-4.6 --platform=${TARGET} --install-dir=${TOOLCHAIN}
fi

export PATH="${TOOLCHAIN}/bin:${PATH}"
export LDFLAGS='-Wl,-z,noexecstack,-z,relro'
export LIBGMP_LDFLAGS='-avoid-version'
export LIBGMPXX_LDFLAGS='-avoid-version'

################################################################################################################

BASE_CFLAGS='-O2 -pedantic -fomit-frame-pointer'

# x86, CFLAGS set according to 'CPU Arch ABIs' in the r8b documentation
export CFLAGS="${BASE_CFLAGS} -march=i686 -msse3 -mstackrealign -mfpmath=sse"
./configure --prefix=/usr --disable-static --build=i686-pc-linux-gnu --host=i686-linux-android
make -j8 V=1 2>&1 | tee android-x86.log
make install DESTDIR=$PWD/x86
cd x86 && mv usr/lib/libgmp.so usr/include/gmp.h . && rm -rf usr && cd ..
make distclean

exit 0
