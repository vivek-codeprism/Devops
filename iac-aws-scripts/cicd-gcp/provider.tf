variable "project" {}
variable "region" {}
variable "zone" {}

provider "google" {
  credentials = "${file(".key/account.json")}"
  project     = "${var.project}"
  region      = "${var.region}"
  zone        = "${var.zone}"
}

provider "kubernetes" {
  host     = "https://${google_container_cluster.kube.endpoint}"
  insecure = true
  username = "${google_container_cluster.kube.master_auth.0.username}"
  password = "${google_container_cluster.kube.master_auth.0.password}"
}
