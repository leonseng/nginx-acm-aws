resource "aws_security_group" "acm" {
  name   = "${random_id.id.dec}-acm"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${local.my_ip}/32"]
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

resource "aws_instance" "acm" {
  ami                    = var.acm_ami
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.ssh_access.key_name
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.acm.id]
  user_data = templatefile(
    "./files/acm.sh.tftpl",
    {
      nms_admin_passwd = local.nms_admin_passwd,
      nms_lic_b64      = var.nms_license_b64
    }
  )

  tags = {
    for k, v in merge(
      {
        Name = "${random_id.id.dec}-acm"
      },
      var.resource_tags
    ) : k => v
  }
}

resource "aws_route53_record" "acm_public" {
  count   = var.route53_zone == "" ? 0 : 1
  zone_id = local.ext_zone_id
  name    = "acm.${local.base_domain}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.acm.public_ip]
}

resource "aws_route53_record" "acm_private" {
  count   = var.route53_zone == "" ? 0 : 1
  zone_id = local.int_zone_id
  name    = "acm.${local.base_domain}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_instance.acm.private_dns]
}

output "acm_public_ip" {
  value = aws_instance.acm.public_ip
}

output "acm_dns" {
  value = var.route53_zone == "" ? null : aws_route53_record.acm_public[0].fqdn
}

output "acm_url" {
  value = var.route53_zone == "" ? "https://${aws_instance.acm.public_ip}" : "https://${aws_route53_record.acm_public[0].fqdn}"
}
