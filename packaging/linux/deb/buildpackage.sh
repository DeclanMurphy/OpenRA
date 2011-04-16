#!/bin/bash
# OpenRA packaging script for Debian based distributions

E_BADARGS=85
if [ $# -ne "3" ]
then
    echo "Usage: `basename $0` version root-dir outputdir"
    exit $E_BADARGS
fi

VERSION=`echo $1 | sed "s/-/\\./g"`

rootdir=`readlink -f $2`
PACKAGE_SIZE=`du --apparent-size -c $rootdir/usr | grep "total" | awk '{print $1}'`

# Copy template files into a clean build directory (required)
mkdir root
cp -R DEBIAN root
cp -R $rootdir/usr root

# Remove duplicate fonts provided by ttf-freefont
rm root/usr/share/openra/FreeSans.ttf
rm root/usr/share/openra/FreeSansBold.ttf

# Put the copyright and changelog in /usr/share/doc/openra/
mkdir -p root/usr/share/doc/openra/
cp copyright root/usr/share/doc/openra/copyright
sed "s/{VERSION}/$VERSION/" changelog > root/usr/share/doc/openra/changelog
cat ./root/usr/share/openra/CHANGELOG >> root/usr/share/doc/openra/changelog

# Create the control file
sed "s/{VERSION}/$VERSION/" DEBIAN/control | sed "s/{SIZE}/$PACKAGE_SIZE/" > root/DEBIAN/control

# Build it in the temp directory, but place the finished deb in our starting directory
pushd root

# Calculate md5sums and clean up the /usr/ part of them
md5sum `find . -type f | grep -v '^[.]/DEBIAN/'` | sed 's/\.\/usr\//usr\//g' > DEBIAN/md5sums

# Start building, the file should appear in the output directory
fakeroot dpkg-deb -b . $3

# Clean up
popd
rm -rf root

