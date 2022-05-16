packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "nginx-apim-r5"
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
  name = "nginx-apim-r5"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "file" {
    source = ".acm-files/platform-repo-518059274.tar.gz"
    destination = "/tmp/platform-repo.tar.gz"
  }

  provisioner "file" {
    source = ".acm-files/nms-apim_1.0.0r5-530316232_focal_amd64.deb"
    destination = "/tmp/nms-apim.deb"
  }

  provisioner "shell" {
    script = "bootstrap.sh"
  }
}
