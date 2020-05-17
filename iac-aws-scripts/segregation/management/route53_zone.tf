variable "domain" {}

resource "aws_route53_zone" "iac" {
  name = "${var.domain}"
}

resource "aws_route53_record" "iac-ns" {
  zone_id = "${aws_route53_zone.iac.zone_id}"
  name    = "${var.domain}"
  type    = "NS"
  ttl     = "30"
  records = [
    "${aws_route53_zone.iac.name_servers.0}",
    "${aws_route53_zone.iac.name_servers.1}",
    "${aws_route53_zone.iac.name_servers.2}",
    "${aws_route53_zone.iac.name_servers.3}",
  ]
}

output "zone" {
  value = "${aws_route53_zone.iac.zone_id}"
}
