variable "domain" {}
variable "zone" {}

resource "aws_route53_record" "api" {
  provider = "aws.management"
  zone_id  = "${var.zone}"
  name     = "api.${terraform.workspace}.${var.domain}"
  type     = "A"
  alias {
    name                   = "${aws_elb.elb.dns_name}"
    zone_id                = "${aws_elb.elb.zone_id}"
    evaluate_target_health = true
  }
}
