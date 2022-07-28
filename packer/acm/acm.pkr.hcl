variable "version" {
  type =  string
}

variable "nginx_repo_cert_path" {
  type =  string
}

variable "nginx_repo_key_path" {
  type =  string
}

locals {
  ami_name = "nginx-acm-${var.version}"
}

packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = local.ami_name
  instance_type = "t2.micro"
  region        = "ap-southeast-2"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["679593333241"]
  }
  ssh_username = "ubuntu"
}

build {
  name = local.ami_name
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

   provisioner "file" {
    sources = [var.nginx_repo_cert_path, var.nginx_repo_key_path]
    destination = "/tmp/"
  }

  provisioner "shell" {
    script = "${path.root}/bootstrap.sh"
  }
}
