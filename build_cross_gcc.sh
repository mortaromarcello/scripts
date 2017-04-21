#! /bin/bash
set -e
trap 'previous_command=$this_command; this_command=$BASH_COMMAND' DEBUG
trap 'echo FAILED COMMAND: $previous_command' EXIT

#-------------------------------------------------------------------------------------------
# This script will download packages for, configure, build and install a GCC cross-compiler.
# Customize the variables (INSTALL_PATH, TARGET, etc.) to your liking before running.
# If you get an error and need to resume the script from some point in the middle,
# just delete/comment the preceding lines before running it again.
#
# See: http://preshing.com/20141119/how-to-build-a-gcc-cross-compiler
#-------------------------------------------------------------------------------------------

SYSROOT=/home/marcellomortaro/build_linux_system
INSTALL_PATH_PASS_ONE=$SYSROOT/tools
LC_ALL=POSIX
SOURCES_PATH=$SYSROOT/usr/local/src
LINUX_ARCH=$(uname -m)
TARGET=$LINUX_ARCH-bls-linux

PARALLEL_MAKE=-j4
BINUTILS_VERSION=2.28
GCC_VERSION=6.2.0
LINUX_KERNEL_VERSION=4.8.9
GLIBC_VERSION=2.25
MPFR_VERSION=3.1.5
GMP_VERSION=6.1.2
MPC_VERSION=1.0.3

PATH=/tools/bin:$PATH
export PATH LC_ALL TARGET
mkdir -vp $SYSROOT
mkdir -vp $INSTALL_PATH_PASS_ONE
sudo ln -svf $INSTALL_PATH_PASS_ONE /
mkdir -vp $SOURCES_PATH
# Download packages
wget -P $SOURCES_PATH -vnc https://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS_VERSION.tar.gz
wget -P $SOURCES_PATH -vnc https://ftp.gnu.org/gnu/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.bz2

wget -P $SOURCES_PATH -vnc https://www.kernel.org/pub/linux/kernel/v4.x/linux-$LINUX_KERNEL_VERSION.tar.xz
wget -P $SOURCES_PATH -vnc https://ftp.gnu.org/gnu/glibc/glibc-$GLIBC_VERSION.tar.xz
wget -P $SOURCES_PATH -vnc https://ftp.gnu.org/gnu/mpfr/mpfr-$MPFR_VERSION.tar.xz
wget -P $SOURCES_PATH -vnc https://ftp.gnu.org/gnu/gmp/gmp-$GMP_VERSION.tar.xz
wget -P $SOURCES_PATH -vnc https://ftp.gnu.org/gnu/mpc/mpc-$MPC_VERSION.tar.gz
# Extract everything
cd $SOURCES_PATH
for dir in binutils-$BINUTILS_VERSION gcc-$GCC_VERSION linux-$LINUX_KERNEL_VERSION glibc-$GLIBC_VERSION mpfr-$MPFR_VERSION gmp-$GMP_VERSION mpc-$MPC_VERSION; do
    if [ -e $dir ]; then
        rm -rvf $dir
    fi
done
for f in *.tar*; do tar xvf $f; done

# Make symbolic links
cd gcc-$GCC_VERSION
ln -sf `ls -1d ../mpfr-*/` mpfr
ln -sf `ls -1d ../gmp-*/` gmp
ln -sf `ls -1d ../mpc-*/` mpc
cd ..

# Step 1. Binutils
if [ -d build-binutils ]; then
    rm -rvf build-binutils
fi
mkdir -vp build-binutils
cd build-binutils
../binutils-$BINUTILS_VERSION/configure --prefix=/tools \
    --with-sysroot=$SYSROOT \
    --with-lib-path=/tools/lib \
    --target=$TARGET \
    --disable-nls \
    --disable-werror
make $PARALLEL_MAKE
######
case $LINUX_ARCH in
    x86_64) mkdir -vp /tools/lib && ln -svf lib /tools/lib64 ;;
esac
######
make install
cd ..

# Step 2. C/C++ Compilers
#######
CURRENT_DIR=$(pwd)
cd $SOURCES_PATH/gcc-$GCC_VERSION
for file in \
    $(find gcc/config -name linux64.h -o -name linux.h -o -name sysv4.h)
    do
        cp -uv $file{,.orig}
        sed -e "s@/lib\(64\)\?\(32\)\?/ld@/tools&@g" \
            -e "s@/usr@/tools@g" $file.orig > $file
    echo -e "
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 \"/tools/lib/\"
#define STANDARD_STARTFILE_PREFIX_2 \"\"" >> $file
    touch $file.orig
done
######
cd $CURRENT_DIR
if [ -d build-gcc ]; then
    rm -rvf build-gcc
fi
mkdir -vp build-gcc
cd build-gcc

../gcc-$GCC_VERSION/configure \
    --target=$TARGET \
    --prefix=/tools \
    --with-glibc-version=2.11 \
    --with-sysroot=$SYSROOT \
    --with-newlib \
    --without-headers \
    --with-local-prefix=/tools \
    --with-native-system-header-dir=/tools/include \
    --disable-nls \
    --disable-shared \
    --disable-multilib \
    --disable-decimal-float \
    --disable-threads \
    --disable-libatomic \
    --disable-libgomp \
    --disable-libmpx \
    --disable-libquadmath \
    --disable-libssp \
    --disable-libvtv \
    --disable-libstdcxx \
    --enable-languages=c,c++
make $PARALLEL_MAKE
make install
cd ..
##########
cd linux-$LINUX_KERNEL_VERSION
make mrproper
make INSTALL_HDR_PATH=dest headers_install
cp -rv dest/include/* /tools/include
cd ..
#########
#    Standard C Library & the rest of Glibc
if [ -d build-glibc ]; then
    rm -rvf build-glibc
fi
mkdir -vp build-glibc
cd build-glibc
../glibc-$GLIBC_VERSION/configure \
    --prefix=/tools \
    --host=$TARGET \
    --build=$(../scripts/config.guess) \
    --enable-kernel=2.6.32 \
    --with-headers=/tools/include \
    libc_cv_forced_unwind=yes \
    libc_cv_c_cleanup=yes
make $PARALLEL_MAKE
make install
echo 'int main(){}' > dummy.c
$TARGET-gcc dummy.c
readelf -l a.out | grep ': /tools'
read
cd ..
#######-----libstdc++
cd build-gcc
../gcc-$GCC_VERSION/libstdc++-v3/configure \
    --host=$TARGET \
    --prefix=/tools \
    --disable-multilib \
    --disable-nls \
    --disable-libstdcxx-threads \
    --disable-libstdcxx-pch \
    --with-gxx-include-dir=/tools/$TARGET/include/c++/6.2.0
make $PARALLEL_MAKE
make install
cd ..
#######- binutils pass2
cd build-binutils
CC=$TARGET-gcc \
AR=$TARGET-ar \
RANLIB=$TARGET-ranlib \
../binutils-$BINUTILS_VERSION/configure \
    --prefix=/tools \
    --disable-dns \
    --disable-werror \
    --with-lib-path=/tools/lib \
    --with-sysroot
make $PARALLEL_MAKE
make install
make -C ld clean
make -C ld LIB_PATH=/usr/lib:/lib
cp -v ld/ld-new /tools/bin
cd ..

########----gcc pass2
rm -rf build-gcc gcc-$GCC_VERSION
tar xvf gcc-$GCC_VERSION.tar*
mkdir build-gcc
CURRENT_DIR=$(pwd)
cd gcc-$GCC_VERSION
ln -sf `ls -1d ../mpfr-*/` mpfr
ln -sf `ls -1d ../gmp-*/` gmp
ln -sf `ls -1d ../mpc-*/` mpc
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
    `dirname $($TARGET-gcc -print-libgcc-file-name)`/include-fixed/limits.h
for file in \
$(find gcc/config -name linux64.h -o -name linux.h -o -name sysv4.h)
do
    cp -uv $file{,.orig}
    sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
        -e 's@/usr@/tools@g' $file.orig > $file
    echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
    touch $file.orig
done
cd $CURRENT_DIR
cd build-gcc
CC=$TARGET-gcc CXX=$TARGET-g++ AR=$TARGET-ar RANLIB=$TARGET-ranlib \
../gcc-$GCC_VERSION/configure \
    --prefix=/tools \
    --with-local-prefix=/tools \
    --with-native-system-header-dir=/tools/include \
    --enable-languages=c,c++ \
    --disable-libstdcxx-pch \
    --disable-multilib \
    --disable-libgomp
make $PARALLEL_MAKE
make install
ln -svf gcc /tools/bin/cc
echo 'int main(){}' > dummy.c
cc dummy.c
readelf -l a.out | grep ': /tools'
read

trap - EXIT
echo 'Success!'
