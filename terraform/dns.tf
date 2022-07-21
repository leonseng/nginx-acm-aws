# Public records
data "aws_route53_zone" "external" {
  name = "aws.leonseng.com."
}

resource "aws_route53_record" "apim_public" {
  zone_id = data.aws_route53_zone.external.zone_id
  name    = "apim.acm-internal.${data.aws_route53_zone.external.name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.apim.public_ip]
}

resource "aws_route53_record" "apigw_public" {
  zone_id = data.aws_route53_zone.external.zone_id
  name    = "apigw.acm-internal.${data.aws_route53_zone.external.name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.apigw.public_ip]
}


resource "aws_route53_record" "devportal_public" {
  zone_id = data.aws_route53_zone.external.zone_id
  name    = "devportal.acm-internal.${data.aws_route53_zone.external.name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.devportal.public_ip]
}

# Private records
resource "aws_route53_zone" "internal" {
  name = data.aws_route53_zone.external.name
  vpc {
    vpc_id = module.vpc.vpc_id
  }
}

resource "aws_route53_record" "apim_private" {
  zone_id = aws_route53_zone.internal.zone_id
  name    = "apim.acm-internal.${data.aws_route53_zone.external.name}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_instance.apim.private_dns]
}

resource "aws_route53_record" "apigw_private" {
  zone_id = aws_route53_zone.internal.zone_id
  name    = "apigw.acm-internal.${data.aws_route53_zone.external.name}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_instance.apigw.private_dns]
}


resource "aws_route53_record" "devportal_private" {
  zone_id = aws_route53_zone.internal.zone_id
  name    = "devportal.acm-internal.${data.aws_route53_zone.external.name}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_instance.devportal.private_dns]
}

resource "aws_route53_record" "devportal_internal_private" {
  zone_id = aws_route53_zone.internal.zone_id
  name    = "acm.devportal.acm-internal.${data.aws_route53_zone.external.name}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_instance.devportal.private_dns]
}
