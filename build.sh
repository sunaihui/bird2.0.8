#!/bin/bash -e
##########################################################################

date=$(date +%y%m%d)
version='2.0.7'

git tag -a "burble-${version}-${date}" -m "burble.dn42 build ${version}/${date}"
git push --tags

# configure

if [ ! -f configure ]
then
    autoreconf
fi

./configure \
    --prefix=/usr \
    --sysconfdir=/etc/bird \
    --localstatedir=/var

# make

make -j4

# create debian package

echo "bird-$version for burble.dn42" > description-pak
sudo checkinstall \
    --default \
    --type='debian' --install=no \
    --pkgname='bird' \
    --pkgversion="$version" \
    --pkgrelease="burble-$date" \
    --maintainer="simon@burble.com" \
    --provides='bird' \
    --strip \
    --backup=no
# reset perms
sudo chown simon.simon *.deb
    
# upload

pkg="bird_${version}-burble-${date}_amd64.deb"
dstdir='minio/artifacts/bird'
dst="${dstdir}/${date}/${pkg}"

mc cp "$pkg" "$dst"
mc cp "$dst" "${dstdir}/current/bird_${version}-burble_amd64.deb"

##########################################################################
# end of file
