# Deploying NGINX ACM on AWS

This directory contains [Terraform](https://www.terraform.io/) files to deploy an NGINX ACM environment on AWS, comprising of the following EC2 instances:
- an ACM management node
- two API gateway nodes
- one devportal node

> To secure the deployment, access to the EC2 instances are locked down to the public IP of the machine that executes the `terraform apply` command.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads)
- NGINX ACM AMIs, built via Packer as detailed [here](../packer/README.md).

## Instructions

1. Create `terraform.tfvars` file based on variables defined in [variables.tf](./variables.tf).
1. Run `terraform apply -auto-approve` to deploy.

Once Terraform has completed the `apply`, run `terraform output -raw acm_url` to get the URL to the NMS web UI. If `nms_admin_password` is not provided, a random password for accessing the NMS web UI is generated instead. It can be retrieved by running `terraform output -raw nms_password`.

## DNS entries for EC2 instances

This Terraform can also automatically create the DNS entries (both public and private) if an existing zone has been registered via AWS Route53. To enable this, simply provide the zone name to the variable `route53_zone`, e.g. `acm-demo.example.com.`. The resulting DNS entries will be available via the `terraform output` command.
