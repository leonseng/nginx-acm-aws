resource "aws_security_group" "apigw" {
  name   = "${random_id.id.dec}-apigw"
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

resource "aws_instance" "apigw" {
  count                  = var.apigw_count
  ami                    = var.apigw_ami
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.ssh_access.key_name
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.apigw.id]
  user_data              = <<EOF
#!/usr/bin/env bash
hostnamectl set-hostname apigw-${count.index}
EOF

  tags = {
    for k, v in merge(
      {
        Name = "${random_id.id.dec}-apigw-${count.index}"
      },
      var.resource_tags
    ) : k => v
  }
}

resource "aws_route53_record" "apigw_public" {
  count   = var.route53_zone == "" ? 0 : var.apigw_count
  zone_id = local.ext_zone_id
  name    = "apigw-${count.index}.${local.base_domain}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.apigw[count.index].public_ip]
}

resource "aws_route53_record" "apigw_cluster_public" {
  count   = var.route53_zone == "" ? 0 : 1
  zone_id = local.ext_zone_id
  name    = "apigw.${local.base_domain}"
  type    = "A"
  ttl     = "300"
  records = aws_instance.apigw[*].public_ip
}

resource "aws_route53_record" "apigw_private" {
  count   = var.route53_zone == "" ? 0 : var.apigw_count
  zone_id = local.int_zone_id
  name    = "apigw-${count.index}.${local.base_domain}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_instance.apigw[count.index].private_dns]
}

output "apigw_public_ip" {
  value = aws_instance.apigw[*].public_ip
}

output "apigw_dns" {
  value = var.route53_zone == "" ? null : aws_route53_record.apigw_public[*].fqdn
}
