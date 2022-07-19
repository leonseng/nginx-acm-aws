
# Downloading packages

Because the deployment in AWS does not have access to F5 corporate network to download the ACM packages, we need to manually download the packages on local dev environment whilst connected via VPN, then include the packages into the build image to be intalled as local .deb packages`

Find dependency of package
```
$ dpkg -I nms-api-connectivity-manager_1.0.0-576811972~focal_amd64.deb
 new Debian package, version 2.0.
 size 9387826 bytes: control archive=2984 bytes.
      63 bytes,     3 lines      conffiles
     328 bytes,    10 lines      control
    1125 bytes,    16 lines      md5sums
    3887 bytes,   130 lines   *  postinst             #!/bin/bash
     175 bytes,     5 lines   *  preinst              #!/bin/bash
     266 bytes,    16 lines   *  prerm                #!/bin/bash
     702 bytes,    41 lines   *  rules                #!/usr/bin/make
 Package: nms-api-connectivity-manager
 Version: 1.0.0-576811972~focal
 Section:
 Priority: optional
 Architecture: amd64
 Maintainer: NGINX, an F5 company
 Installed-Size: 24319
 Depends: nms-instance-manager (>= 2.3)
 Homepage: https://www.nginx.com/products/nginx-api-control-manager/
 Description: NGINX Management Suite ACM Module.
```

List package version on repo
```
$ apt-cache policy nms-instance-manager
nms-instance-manager:
  Installed: (none)
  Candidate: 2.3.0-576497107~focal
  Version table:
     2.3.0-576497107~focal 500
        500 https://sea.artifactory.f5net.com/artifactory/f5-nginx-debian focal/nms-instance-manager amd64 Packages
     2.2.0-535339999~focal 500
        500 https://sea.artifactory.f5net.com/artifactory/f5-nginx-debian focal/nms-instance-manager amd64 Packages
```

# Building images

Create `variables.pkrvars.hcl` with the following variables
```

```

Build the images with the following commands
```
packer build -var-file=variables.pkrvars.hcl apigw/
packer build -var-file=variables.pkrvars.hcl apim/
packer build -var-file=variables.pkrvars.hcl devportal/
```