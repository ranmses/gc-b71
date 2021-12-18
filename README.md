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
```

On Amazon Linux 2, install the newer openssl-libs:
```shell
yum install openssl11-libs
```

For testing purposes, the `harmony-one.repo` file assumes that this repository was cloned to `/tmp/gc-b71`.

Testing:
```shell
yum list harmony-one --showduplicates
# Loaded plugins: langpacks, priorities, update-motd
# Available Packages
# harmony-one.x86_64           4.0.0-0            harmony-one_gc-b71
# harmony-one.x86_64           4.0.1-0            harmony-one_gc-b71
# harmony-one.x86_64           4.1.0-0            harmony-one_gc-b71
# harmony-one.x86_64           4.1.1-0            harmony-one_gc-b71
# harmony-one.x86_64           4.1.2-0            harmony-one_gc-b71
# harmony-one.x86_64           4.1.3-0            harmony-one_gc-b71
# harmony-one.x86_64           4.1.4-0            harmony-one_gc-b71
# harmony-one.x86_64           4.1.5-0            harmony-one_gc-b71
# harmony-one.x86_64           4.1.6-0            harmony-one_gc-b71
# harmony-one.x86_64           4.1.7-0            harmony-one_gc-b71
# harmony-one.x86_64           4.1.8-0            harmony-one_gc-b71
# harmony-one.x86_64           4.1.9-0            harmony-one_gc-b71
# harmony-one.x86_64           4.1.10-0           harmony-one_gc-b71
# harmony-one.x86_64           4.2.0-0            harmony-one_gc-b71
# harmony-one.x86_64           4.2.1-0            harmony-one_gc-b71
# harmony-one.x86_64           4.3.0-0            harmony-one_gc-b71
yum install harmony-one
harmony version
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

## Final remarks (October/2021)

### Building server
I've used a machine running RHEL 8.4 with go1.17.2 installed from source because the official Red Hat repository doesn't provide golang later than 1.15.
All commands should be executed by *root*.

### Golang version
On the spec file, the `%build` section checks if the Golang version on the building machine is newer
than the requirement in the `go.mod` file from the harmony repo. 

### Amazon Linux 2 vs RHEL 8
Amazon Linux 2 is based on RHEL 7, not on RHEL 8 (hence the need for `openssl11-libs`, only available for EL7-based distros).

Nevertheless, the same RPM seems to provide working binaries on all platforms. One should note that, in the future, this difference between distros may impose a need for more than one RPM build for each version, e.g. *el7* and *el8*.

### Everything else
I had to make assumptions during development, please let me know if you need anything.

## Additional remarks (December/2021)

### Platforms
All testing has been done on virtual machines, since it is the recommended approach for RPM development and there was no mention of container testing in the bounty's description. All steps should work as expected if the same platforms are used for the same purposes (meaning RHEL8 to build RPMs which can be installed on other distros for client testing).

### VM Images
| Link/How to obtain                                                      | Filename/Versions                |
| ----------------------------------------------------------------------- | -------------------------------- |
| [RHEL 8 download](https://developers.redhat.com/products/rhel/download) | `rhel-8.4-x86_64-dvd.iso`        |
| [CentOS 8 isos](http://isoredirect.centos.org/centos/8/isos/x86_64/)    | `CentOS-8.4.2105-x86_64-dvd.iso` | 
| [Amazon Linux 2 on premises](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/amazon-linux-2-virtual-machine.html) | `amzn2-vmware_esx-2.0.20211005.0-x86_64.xfs.gpt.ova` | 

### Golang
With the 8.5 releases of RHEL and CentOS, go1.16.7 is now available for install using yum. The `pre_rpmbuild.sh` shellscript has been modified to leverage that.

### Container Testing - Intro
Compiling software or developing RPMs on containers is **not** recommended (best to just provide customized docker images with the software already installed instead). But it is *possible* to make it work on *some* cases.

During evaluation I was made aware of the Harmony team desire to use containers for development and testing, so I decided to make this acommodation.

### Container Testing - Steps

#### 1. RPM build
The RPM file will be built *inside* the container.

```terminal
ranmses@onehost /tmp $ git clone https://github.com/ranmses/gc-b71.git
ranmses@onehost /tmp $ docker run -itd --name centos8-server centos:latest
ranmses@onehost /tmp $ docker cp gc-b71 centos8-server:/tmp
ranmses@onehost /tmp $ docker attach centos8-server
[root@40cdbf5b2e35 ~]# cd /tmp/gc-b71/
[root@40cdbf5b2e35 gc-b71]# ./pre_rpmbuild.sh 4.3.1
Sat Dec 18 00:06:31 UTC 2021
CentOS Linux 8 - AppStream                      4.1 MB/s | 8.2 MB     00:01    
CentOS Linux 8 - BaseOS                         2.5 MB/s | 3.5 MB     00:01    
CentOS Linux 8 - Extras                          20 kB/s |  10 kB     00:00    
Dependencies resolved.
...
Note: switching to '65614950c7f8bfdb01123017ede083c240e8afaa'.
...
Turn off this advice by setting config variable advice.detachedHead to false

[root@40cdbf5b2e35 gc-b71]# rpmbuild -bb /root/rpmbuild/SPECS/harmony-one-4.3.1.spec
Executing(%prep): /bin/sh -e /var/tmp/rpm-tmp.BGBxFs
+ umask 022
+ cd /root/rpmbuild/BUILD
...
+ go mod tidy
+ make
+ exit 0
Executing(%install): /bin/sh -e /var/tmp/rpm-tmp.OP8dao
...
Wrote: /root/rpmbuild/RPMS/x86_64/harmony-one-4.3.1-0.x86_64.rpm
Executing(%clean): /bin/sh -e /var/tmp/rpm-tmp.zQNwBr
+ umask 022
+ cd /root/rpmbuild/BUILD
+ cd harmony-one-4.3.1
+ rm -rf /root/rpmbuild/BUILD/harmony-one-4.3.1
+ rm -rf /root/rpmbuild/BUILDROOT/harmony-one-4.3.1-0.x86_64
+ exit 0
```
Having generated the RPM file, let's create a local yum repo and copy it back to host so we can test on clients with `yum install harmony-one`.

```terminal
[root@40cdbf5b2e35 gc-b71]# yum install -y createrepo
[root@40cdbf5b2e35 gc-b71]# cd pub/yum/x86_64/
[root@40cdbf5b2e35 x86_64]# rm -rf *
[root@40cdbf5b2e35 x86_64]# cp /root/rpmbuild/RPMS/x86_64/*.rpm .
[root@40cdbf5b2e35 x86_64]# createrepo .
Directory walk started
...
Pool finished
[root@40cdbf5b2e35 x86_64]# pwd
/tmp/gc-b71/pub/yum/x86_64
[root@40cdbf5b2e35 x86_64]# exit
ranmses@onehost /tmp $ docker cp centos8-server:/tmp/gc-b71 gc-b71_newbuild
```
#### 2. Client testing

Now we push the new build to clients and test it out.

Test #1 - CentOS 8:
```terminal
ranmses@onehost /tmp $ docker run -itd --name centos8-client centos:latest
ranmses@onehost /tmp $ docker cp gc-b71_newbuild centos8-client:/tmp/gc-b71
ranmses@onehost /tmp $ docker attach centos8-client
[root@34def7ec8d8e /]# cp /tmp/gc-b71/harmony-one.repo /etc/yum.repos.d/.
[root@34def7ec8d8e /]# yum install -y harmony-one
CentOS Linux 8 - AppStream                                        2.8 MB/s | 8.2 MB     00:02    
CentOS Linux 8 - BaseOS                                           2.1 MB/s | 3.5 MB     00:01    
CentOS Linux 8 - Extras                                           355  B/s |  10 kB     00:30    
Harmony One - Gitcoin Bounty 71                                   698 kB/s | 1.1 kB     00:00
Dependencies resolved.
=============================================================================================
 Package             Architecture   Version                 Repository                  Size
=============================================================================================
Installing:
 harmony-one         x86_64         4.3.1-0                 harmony-one_gc-b71          19 M
Installing dependencies:
 gmp-c++             x86_64         1:6.1.2-10.el8          baseos                      33 k
 gmp-devel           x86_64         1:6.1.2-10.el8          baseos                     187 k

Transaction Summary
=============================================================================================
Install  3 Packages
...
Installed:
  gmp-c++-1:6.1.2-10.el8.x86_64  gmp-devel-1:6.1.2-10.el8.x86_64  harmony-one-4.3.1-0.x86_64 

Complete!
[root@34def7ec8d8e /]# harmony version
Harmony (C) 2020. harmony, version v7211-v4.3.1-0-g65614950-dirty (root@ 2021-12-18T00:12:43+0000)
[root@34def7ec8d8e /]# exit
```

Test #2 - Amazon Linux 2:
```terminal
ranmses@onehost /tmp $ docker run -itd --name amzn2-client amazonlinux:2
ranmses@onehost /tmp $ docker cp gc-b71_newbuild amzn2-client:/tmp/gc-b71
ranmses@onehost /tmp $ docker attach amzn2-client                        
bash-4.2# cp /tmp/gc-b71/harmony-one.repo /etc/yum.repos.d/.
bash-4.2# yum install -y openssl11-libs
Loaded plugins: ovl, priorities
amzn2-core                                                                   | 3.7 kB  00:00:00     
harmony-one_gc-b71                                                           | 3.0 kB  00:00:00     
...
Installed:
  openssl11-libs.x86_64 1:1.1.1g-12.amzn2.0.4                                                       

Dependency Installed:
  openssl11-pkcs11.x86_64 0:0.4.10-6.amzn2.0.1                                                      

Complete!
bash-4.2# yum install -y harmony-one
Loaded plugins: ovl, priorities
Resolving Dependencies
--> Running transaction check
---> Package harmony-one.x86_64 0:4.3.1-0 will be installed
--> Processing Dependency: gmp-devel for package: harmony-one-4.3.1-0.x86_64
--> Running transaction check
---> Package gmp-devel.x86_64 1:6.0.0-15.amzn2.0.2 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

====================================================================================================
 Package             Arch           Version                        Repository                  Size
====================================================================================================
Installing:
 harmony-one         x86_64         4.3.1-0                        harmony-one_gc-b71          19 M
Installing for dependencies:
 gmp-devel           x86_64         1:6.0.0-15.amzn2.0.2           amzn2-core                 181 k

Transaction Summary
====================================================================================================
Install  1 Package (+1 Dependent package)
...
Installed:
  harmony-one.x86_64 0:4.3.1-0                                                                      

Dependency Installed:
  gmp-devel.x86_64 1:6.0.0-15.amzn2.0.2                                                             

Complete!
bash-4.2# harmony version
Harmony (C) 2020. harmony, version v7211-v4.3.1-0-g65614950-dirty (root@ 2021-12-18T00:12:43+0000)
bash-4.2# exit
```
