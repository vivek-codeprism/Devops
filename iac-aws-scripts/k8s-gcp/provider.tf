variable "project" {}
variable "region" {}
variable "zone" {}

provider "google-beta" {
  credentials = "${file(".key/account.json")}"
  project     = "${var.project}"
  region      = "${var.region}"
  zone        = "${var.zone}"
}

provider "kubernetes" {}
