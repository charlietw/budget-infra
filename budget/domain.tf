resource "aws_route53_record" "budget" {
  zone_id = var.hosted_zone_id
  name    = "budgettesting"
  type    = "A"
  ttl     = "5"
  records = [aws_instance.terraform_ec2.public_ip]
}
