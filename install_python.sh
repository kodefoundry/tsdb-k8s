#!/bin/sh
PYTHON_VERSION=3.9.6
mkdir -p /usr/src && cd /usr/src
curl -O https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz
tar -xvf Python-${PYTHON_VERSION}.tar.xz
cd Python-${PYTHON_VERSION}

gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"
./configure \
--build="$gnuArch" \
--prefix=/opt/python/${PYTHON_VERSION} \
--enable-shared \
--enable-ipv6 \
--enable-loadable-sqlite-extensions \
--enable-optimizations \
--enable-option-checking=fatal \
--enable-shared \
--with-system-expat \
--with-system-ffi
#--without-ensurepip

make -j "$(nproc)" EXTRA_CFLAGS="-DTHREAD_STACK_SIZE=0x100000" \
LDFLAGS=-Wl,--strip-all,-rpath=/opt/python/${PYTHON_VERSION}/lib,--disable-new-dtags
make install
find /opt/python -depth \
		\( \
			\( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
			-o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name '*.a' \) \) \
		\) -exec rm -rf '{}' +

find /opt/python -type f -executable -not \( -name '*tkinter*' \) -exec scanelf --needed --nobanner --format '%n#p' '{}' ';' \
		| tr ',' '\n' \
		| sort -u \
		| awk 'system("[ -e /opt/python/3.9.6/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
		| xargs -rt apk add --no-cache --virtual .python-rundeps


ln -s /opt/python/3.9.6/bin/python3 /usr/local/bin/python3
ln -s /opt/python/3.9.6/bin/pip3 /usr/local/bin/pip3
ln -s /usr/local/bin/python3 /usr/local/bin/python
ln -s /usr/local/bin/pip3 /usr/local/bin/pip
rm -rf /usr/src