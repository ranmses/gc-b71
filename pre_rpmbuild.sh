#!/bin/bash
[[ ! -z "$1" ]] && hvrs="$1" || { echo "Please inform the desired Harmony version e.g. '$0 4.3.0'"; exit 1; }
yum install -y git --quiet
yum groupinstall -y "RPM Development Tools" --quiet
rpmdev-setuptree
sdir=/root/rpmbuild/SOURCES/
cd ${sdir}
harm="harmony-one-${hvrs}/go/src/github.com/harmony-one"
rm -rf ${harm}
mkdir -p ${harm} && cd ${harm}
(
git clone --quiet "https://github.com/harmony-one/mcl.git"
git clone --quiet "https://github.com/harmony-one/bls.git"
git clone --quiet "https://github.com/harmony-one/harmony.git" --branch "v${hvrs}"
) &> /dev/null
cd harmony
# go version requirement and repo release
gvrs=$(egrep "^go" go.mod  | cut -d' ' -f2)
hrel=$(git describe --long | cut -d'-' -f2)
# spec file
spec=/root/rpmbuild/SPECS/harmony-one-${hvrs}.spec
cp -f /images/gc-b71/harmony-one.spec.template ${spec}
sed -i "s/HVRS/$hvrs/g" ${spec}
sed -i "s/HREL/$hrel/g" ${spec}
sed -i "s/GVRS/$gvrs/g" ${spec}
cd ${sdir}
tar -cf harmony-one-${hvrs}.tar harmony-one-${hvrs}
rm -rf harmony-one-${hvrs}
exit 0