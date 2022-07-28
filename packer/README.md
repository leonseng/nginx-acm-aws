# Building AMIs

This directory contains Packer files to build AWS Machine Image for the following components in the NGINX ACM demo:
1. ACM management
1. Devportal
1. API gateway


## Prerequisites

The certificate and key for accessing NGINX repo is required for installing the NGINX ACM components.

## Instructions

1. Create `variables.pkrvars.hcl` in this directory with the following variables
      | Variable | Description |
      | --- | --- |
      | `version` | Suffic to append to AMI names |
      | `nginx_repo_cert_path` | Full path to certificate for accessing NGINX repo |
      | `nginx_repo_key_path` | Full path to key for accessing NGINX repo |

      See [variables.pkrvars.hcl.example](./variables.pkrvars.hcl.example) for an example.
1. Build the images with the following commands
      ```
      packer build -var-file=variables.pkrvars.hcl acm/
      packer build -var-file=variables.pkrvars.hcl apigw/
      packer build -var-file=variables.pkrvars.hcl devportal/
      ```

      Each command will output the AMI ID for the corresponding ACM component, as below, which will be used as inputs to the Terraform project for deploying the EC2
      ```
      ==> Builds finished. The artifacts of successful builds are:
      --> nms-apigw-1.0.0.amazon-ebs.ubuntu: AMIs were created:
      ap-southeast-2: ami-04f4ea46fafd660d3
      ```