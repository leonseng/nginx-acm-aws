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

data "aws_availability_zones" "local_az" {
  state = "available"
  filter {
    name   = "region-name"
    values = [var.region]
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                 = random_id.id.dec
  cidr                 = "10.0.0.0/16"
  azs                  = [data.aws_availability_zones.local_az.names[0]]
  public_subnets       = ["10.0.1.0/24"]
  enable_nat_gateway   = true
  enable_dns_hostnames = true
  tags = {
    "Owner" = var.owner
  }
}

resource "aws_key_pair" "ssh_access" {
  public_key = var.ssh_public_key
}

resource "aws_security_group" "all_sg" {
  name   = "${random_id.id.dec}-all-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32", "10.0.0.0/16"]
  }

  ingress {
    description = "internal"
    from_port   = 81
    to_port     = 81
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32", "10.0.0.0/16"]
  }

  ingress {
    description = "ping"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32", "10.0.0.0/16"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_instance" "apim" {
  depends_on = [
    aws_key_pair.ssh_access,
    aws_security_group.all_sg
  ]
  ami                    = var.apim_ami
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.ssh_access.key_name
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.all_sg.id]
  user_data              = templatefile("./files/apim.sh.tftpl", { nms_admin_password = var.apim_nms_admin_password, nms_nim_lic_b64 = var.apim_nms_lic_b64 })

  tags = {
    Name  = "${random_id.id.dec}-apim"
    Owner = var.owner
  }
}

resource "aws_instance" "apigw" {
  depends_on = [
    aws_key_pair.ssh_access,
    aws_security_group.all_sg
  ]
  ami                    = var.apigw_ami
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.ssh_access.key_name
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.all_sg.id]
  user_data              = <<EOF
#!/usr/bin/env bash
hostnamectl set-hostname apigw
EOF
  tags = {
    Name  = "${random_id.id.dec}-apigw"
    Owner = var.owner
  }
}

resource "aws_instance" "devportal" {
  depends_on = [
    aws_key_pair.ssh_access,
    aws_security_group.all_sg
  ]
  ami                    = var.devportal_ami
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.ssh_access.key_name
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.all_sg.id]
  user_data              = <<EOF
#!/usr/bin/env bash
hostnamectl set-hostname devportal
EOF

  tags = {
    Name  = "${random_id.id.dec}-devportal"
    Owner = var.owner
  }
}
