
resource "aws_security_group" "devportal" {
  name   = "${random_id.id.dec}-devportal"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${local.my_ip}/32"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${local.my_ip}/32", local.vpc_cidr]
  }

  ingress {
    description = "devportal internal"
    from_port   = 81
    to_port     = 81
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${local.my_ip}/32", local.vpc_cidr]
  }

  ingress {
    description = "ping"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["${local.my_ip}/32", local.vpc_cidr]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_instance" "devportal" {
  ami                    = var.devportal_ami
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.ssh_access.key_name
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.devportal.id]
  user_data = <<-END
    #cloud-config
    ${jsonencode({
  write_files = [
    {
      path        = "/etc/ssl/nginx/nginx-repo.crt"
      permissions = "0644"
      owner       = "root:root"
      encoding    = "b64"
      content     = filebase64("${var.nginx_repo_cert_path}")
    },
    {
      path        = "/etc/ssl/nginx/nginx-repo.key"
      permissions = "0644"
      owner       = "root:root"
      encoding    = "b64"
      content     = filebase64("${var.nginx_repo_key_path}")
    },
  ],
  hostname = "devportal"
})}
END

tags = {
  for k, v in merge(
    {
      Name = "${random_id.id.dec}-devportal"
    },
    var.resource_tags
  ) : k => v
}
}

resource "aws_route53_record" "devportal_public" {
  count   = var.route53_zone == "" ? 0 : 1
  zone_id = local.ext_zone_id
  name    = "devportal.${local.base_domain}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.devportal.public_ip]
}

resource "aws_route53_record" "devportal_private" {
  count   = var.route53_zone == "" ? 0 : 1
  zone_id = local.int_zone_id
  name    = "devportal.${local.base_domain}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_instance.devportal.private_dns]
}

resource "aws_route53_record" "devportal_internal_private" {
  count   = var.route53_zone == "" ? 0 : 1
  zone_id = local.int_zone_id
  name    = "acm.devportal.${local.base_domain}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_instance.devportal.private_dns]
}

output "devportal_public_ip" {
  value = aws_instance.devportal.public_ip
}

output "devportal_dns" {
  value = var.route53_zone == "" ? null : aws_route53_record.devportal_public[0].fqdn
}

output "devportal_url" {
  value = var.route53_zone == "" ? "http://${aws_instance.devportal.public_ip}" : "http://${aws_route53_record.devportal_public[0].fqdn}"
}
