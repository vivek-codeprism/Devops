variable "access_key" {}
variable "secret_key" {}
variable "region_aws" {}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region_aws}"
}

variable "letsencrypt_url" {}

provider "acme" {
  server_url = "${var.letsencrypt_url}"
}
