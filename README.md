# NGINX ACM on AWS

This repository contains files to deploy an [NGINX API Connectivity Manager](https://docs.nginx.com/nginx-management-suite/) environment on AWS.

![](./docs/acm-tf.png)

## Instructions

Begin with the [Packer project](./packer) to build the NGINX ACM component AMIs. Then deploy the ACM components on AWS with the [Terraform project](./terraform/).
