# Gitcoin - Bounty 71

## Usage

### 1. Building RPMs (server)
Install the needed yum packages and generate both source and spec files:
```shell
./pre_rpmbuild.sh ${version}
ls -l /root/rpmbuild/SPECS/harmony-one-${version}.spec
ls -l /root/rpmbuild/SOURCES/harmony-one-${version}.tar
```

Then build the RPM package:
```shell
rpmbuild -bb /root/rpmbuild/SPECS/harmony-one-${version}.spec
ls -l /root/rpmbuild/RPMS/x86_64/harmony-one-${version}-${release}.x86_64.rpm
```

For demonstration purposes, the `pub/yum/x86_64` directory contains all v4.x.x RPMs created as follows:
```shell
for v in $(cat versions.txt) ; do ./pre_rpmbuild.sh ${v} && rpmbuild -bb /root/rpmbuild/SPECS/harmony-one-${v}.spec ; done
```

### 2. Populating the yum repository (server)
Add new RPMs to repo:
```shell
yum install createrepo
cp /root/rpmbuild/RPMS/x86_64/*.rpms pub/yum/x86_64/.
cd pub/yum/x86_64
createrepo .
```

### 3. Testing 'yum install harmony-one' (client)
Copy the repo file:
```shell
cp harmony-one.repo /etc/yum.repos.d/.
yum clean all && yum repolist
yum install harmony-one
```

On Amazon Linux 2, install the newer openssl-libs:
```shell
yum install openssl11-libs
```

For testing purposes, the `harmony-one.repo` file assumes that this repository was cloned to `/tmp/gc-b71`.

Testing:
```shell
yum list harmony-one --showduplicates
yum install harmony-one
# Harmony (C) 2020. harmony, version v7174-v4.3.0-0-g15f9b2d1 (root@ 2021-10-30T02:31:53-0300)
yum remove harmony-one
yum install harmony-one-4.0.0
harmony version
# Harmony (C) 2020. harmony, version v6933-v4.0.0-0-g78759217 (root@ 2021-10-30T04:06:49-0300)
```

## Comments - Description and Acceptance Criteria

> Package and distribute the Harmony binaries for Linux's CentOS/RHEL/AL2 distribution. For example, CentOS's yum install harmony-one should initiate installation of Harmony binaries alongside all the dependencies. Also allow the installation to be pinned to a certain version.

This sets the package name to *harmony-one*. The RPM package installs binaries *harmony* and *bootnode*; it also installs *mcl* and *bls* libs. The harmony version should be user-defined as desired in #1. Both release and go version requirement are dynamically defined.

> Create the necessary dependency metadata initially with a personal repo (to point to Harmony later on)

See the `harmony-one.repo` file and the `pub/yum/x86_64` directory.

> Provide the guidelines on how to add the source RPM-based CentOS/RHEL/AL2 to enable installs

See #3. Tested with clients running RHEL 8.4, CentOS 8.4 and Amazon Linux 2.

> Ensure the setup and installation abides by Harmony and Linux guidelines (e.g. permissions, install path, etc.)

See the `harmony-one.spec.template` file.

> Document the steps necessary to post the latest builds to the Linux repositories, if any

See #1 and #2.

> Submit the changes to Harmony and review with the Harmony team

Done through gitcoin.

## Final remarks

### Building server
I've used a machine running RHEL 8.4 with go1.17.2 installed from source
because the official Red Hat repository doesn't provide golang later than 1.15.
All commands should be executed by *root*.

### Golang version
On the spec file, the `%build` section checks if the Golang version on the building machine is newer
than the requirement in the `go.mod` file from the harmony repo. 

### Amazon Linux 2 vs RHEL 8
Amazon Linux 2 is based on RHEL 7, not on RHEL 8 (hence the need for `openssl11-libs`, only available for EL7-based
distros). Nevertheless, the same RPM seems to provide working binaries on all platforms. One should note that, in the future, this difference between distros may impose a need for more than one RPM build for each version, e.g. *el7*
and *el8*.

### Everything else
I had to make assumptions during development, please let me know if you need anything.