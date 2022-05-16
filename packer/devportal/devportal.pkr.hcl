packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "nginx-devportal-r5"
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
  name = "nginx-devportal-r5"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "file" {
    sources = [".acm-files/nginx-repo.crt", ".acm-files/nginx-repo.key"]
    destination = "/tmp/"
  }

  provisioner "file" {
    source = ".acm-files/nginx-devportal_1.0.0r5.530315185_focal_amd64.deb"
    destination = "/tmp/nginx-devportal.deb"
  }

  provisioner "file" {
    source = ".acm-files/nginx-devportal-ui_1.0.0r5.530314375_focal_amd64.deb"
    destination = "/tmp/nginx-devportal-ui.deb"
  }

  provisioner "shell" {
    script = "bootstrap.sh"
  }
}
