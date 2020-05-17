variable "access_key" {
  type = "map"
}
variable "secret_key" {
  type = "map"
}
variable "region" {}

provider "aws" {
  alias      = "management"
  access_key = "${var.access_key["management"]}"
  secret_key = "${var.secret_key["management"]}"
  region     = "${var.region}"
}

provider "aws" {
  alias      = "staging"
  access_key = "${var.access_key["staging"]}"
  secret_key = "${var.secret_key["staging"]}"
  region     = "${var.region}"
}

provider "aws" {
  alias      = "production"
  access_key = "${var.access_key["production"]}"
  secret_key = "${var.secret_key["production"]}"
  region     = "${var.region}"
}
