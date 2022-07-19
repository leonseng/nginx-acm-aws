variable "version" {
  type =  string
}

variable "nms_acm_binary_path" {
  type =  string
  default = ".acm-files/nms-api-connectivity-manager.deb"
}

variable "nms_instance_manager_binary_path" {
  type =  string
  default = ".acm-files/nms-instance-manager.deb"
}

locals {
  ami_name = "nginx-apim-${var.version}"
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
    source = var.nms_instance_manager_binary_path
    destination = "/tmp/nms-instance-manager.deb"
  }

  provisioner "file" {
    source = var.nms_acm_binary_path
    destination = "/tmp/nms-api-connectivity-manager.deb"
  }

  provisioner "shell" {
    script = "${path.root}/bootstrap.sh"
  }
}
