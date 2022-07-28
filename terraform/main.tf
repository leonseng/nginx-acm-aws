provider "aws" {
  region = var.region
}

resource "random_id" "id" {
  byte_length = 4
  prefix      = "nginx-acm-"
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "random_string" "this" {
  length  = 12
  special = false
}

locals {
  vpc_cidr         = "10.0.0.0/16"
  my_ip            = chomp(data.http.myip.body)
  nms_admin_passwd = var.nms_admin_password == "" ? random_string.this.result : var.nms_admin_password
}

data "aws_availability_zones" "this" {
  state = "available"
  filter {
    name   = "region-name"
    values = [var.region]
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                 = random_id.id.dec
  cidr                 = local.vpc_cidr
  azs                  = [data.aws_availability_zones.this.names[0]]
  public_subnets       = [cidrsubnet(local.vpc_cidr, 8, 1)]
  enable_nat_gateway   = true
  enable_dns_hostnames = true
  tags                 = var.resource_tags
}

resource "aws_key_pair" "ssh_access" {
  public_key = var.ssh_public_key
}

# DNS
data "aws_route53_zone" "external" {
  count = var.route53_zone == "" ? 0 : 1
  name  = var.route53_zone
}

locals {
  ext_zone_id = var.route53_zone == "" ? null : data.aws_route53_zone.external[0].zone_id
  base_domain = var.route53_zone == "" ? null : "acm-demo.${data.aws_route53_zone.external[0].name}"
}

# Private records for EC2 instances to communicate within VPC
resource "aws_route53_zone" "internal" {
  count = var.route53_zone == "" ? 0 : 1
  name  = var.route53_zone
  vpc {
    vpc_id = module.vpc.vpc_id
  }
}

locals {
  int_zone_id = var.route53_zone == "" ? null : aws_route53_zone.internal[0].zone_id
}

output "nms_password" {
  value     = local.nms_admin_passwd
  sensitive = true
}
