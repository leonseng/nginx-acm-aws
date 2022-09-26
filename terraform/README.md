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

This Terraform can also automatically create the DNS entries (both public and private) if an existing zone has been registered via AWS Route53. To enable this, simply provide the zone name to the Terraform variable `route53_zone`, e.g. `acm-demo.example.com.`. The following DNS records will be created:

| Record Name | Example | Description |
| --- | --- | --- |
| `acm.<zone>` | `acm.acm-demo.example.com  A  100.200.100.10` | Resolves to public IP address of the ACM EC2 instance. When queried within VPC, resolves to private IP of the ACM EC2 instance. |
| `apigw-<n>.<zone>` | `apigw-0.acm-demo.example.com  A  100.200.100.20`<br />`apigw-1.acm-demo.example.com  A  100.200.100.21` | Individual records (with `n` starting from `0`) that resolves to public IP address of each API gateway EC2 instance. When queried within VPC, resolves to private IP addresses of the API gateway EC2 instance. |
| `apigw.<zone>` | `apigw.acm-demo.example.com  A  100.200.100.20`<br />`                     100.200.100.21` | Resolves to public IP addresses of all API gateway EC2 instances. This will be the FQDN used by clients to access the APIs. |
| `devportal.<zone>` | `devportal.acm-demo.example.com  A  100.200.100.30` | Resolves to public IP address of the developer portal EC2 instances. This will be the FQDN used by clients to access the Developer Portal. When queried within VPC, resolves to private IP of the ACM EC2 instance. |
| `acm.devportal.<zone>` | `acm.devportal.acm-demo.example.com  A  10.0.0.30` | Resolves to private IP address of the developer portal EC2 instances. This will be used by the ACM instance for internal communicaitons to the developer portal instance. |

The resulting DNS entries will be available via the `terraform output` command.
