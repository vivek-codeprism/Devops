variable "email" {}

resource "tls_private_key" "private_key" {
  algorithm   = "RSA"
  ecdsa_curve = "P256"
}

resource "acme_registration" "reg" {
  account_key_pem = "${tls_private_key.private_key.private_key_pem}"
  email_address   = "${var.email}"
}

resource "acme_certificate" "cert" {
  account_key_pem = "${acme_registration.reg.account_key_pem}"
  common_name     = "*.${var.domain}"

  dns_challenge {
    provider = "route53"

    config {
      AWS_ACCESS_KEY_ID     = "${var.access_key}"
      AWS_SECRET_ACCESS_KEY = "${var.secret_key}"
      AWS_DEFAULT_REGION    = "${var.region_aws}"
      AWS_HOSTED_ZONE_ID    = "${data.aws_route53_zone.zone.zone_id}"
    }
  }
}

resource "aws_acm_certificate" "cert" {
  private_key       = "${acme_certificate.cert.private_key_pem}"
  certificate_body  = "${acme_certificate.cert.certificate_pem}"
  certificate_chain = "${acme_certificate.cert.issuer_pem}"
}
