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
  account_key_pem           = "${tls_private_key.private_key.private_key_pem}"
  common_name               = "api.${terraform.workspace}.${var.domain}"
  dns_challenge {
    provider = "route53"
    config {
      AWS_ACCESS_KEY_ID     = "${var.access_key[terraform.workspace]}"
      AWS_SECRET_ACCESS_KEY = "${var.secret_key[terraform.workspace]}"
      AWS_DEFAULT_REGION    = "${var.region}"
      AWS_HOSTED_ZONE_ID    = "${var.zone}"
    }
  }
}

resource "aws_iam_server_certificate" "cert" {
  certificate_body = "${acme_certificate.cert.certificate_pem}"
  private_key      = "${acme_certificate.cert.private_key_pem}"
}
