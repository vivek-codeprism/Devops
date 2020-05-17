variable "private_key" {}
variable "couchdb_host" {}
variable "couchdb_port" {}
variable "couchdb_user" {}
variable "couchdb_pass" {}
variable "region" {}
variable "size" {}
variable "webhook_url" {}
variable "domain" {}
variable "email" {}
variable "user" {
  type = "list"
}

locals {
  image       = "centos-7-x64"
  prefix      = "c3s"
  environment = ["test"]
  user        = "${var.user}" # public keys needs to be placed to .key dir

  /*
  endpoint = [
    "/user-services/_session",
    "/api/getUserInfo/test_test",
    "/api/getIngredientCategories",
  ]

  url = "${formatlist(join(",", formatlist("\"http://app.%%s.${var.domain}%s\"", local.endpoint)),
    local.environment,
    local.environment,
    local.environment)}//
*/
}

resource "digitalocean_ssh_key" "auth" {
  count      = "${length(local.user)}"
  name       = "${local.prefix}-${element(local.user, count.index)}"
  public_key = "${file(".key/${element(local.user, count.index)}.pub")}"
}

module "test" {
  source       = "./environment"
  environment  = "test"
  public_key   = ["${digitalocean_ssh_key.auth.*.id}"]
  private_key  = "${file(var.private_key)}"
  couchdb_host = "${var.couchdb_host}"
  couchdb_port = "${var.couchdb_port}"
  couchdb_user = "${var.couchdb_user}"
  couchdb_pass = "${var.couchdb_pass}"
  image        = "${local.image}"
  prefix       = "${local.prefix}"
  region       = "${var.region}"
  size         = "${var.size}"
  domain       = "${var.domain}"
  email        = "${var.email}"
  access_key   = "${var.access_key}"
  secret_key   = "${var.secret_key}"
  region_aws   = "${var.region_aws}"
}
