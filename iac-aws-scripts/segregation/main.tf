variable "ami_id" {}
variable "domain" {}
variable "backet" {}
variable "mgt_account" {}
variable "env_account" {type = "map"}
variable "itype" {}

module "management" {
  source    = "./management"
  providers = {
    aws = "aws.management"
  }
  ami_id  = "${var.ami_id}"
  account = "${var.env_account}"
  domain  = "${var.domain}"
  backet  = "${var.backet}"
  region  = "${var.region}"
  itype   = "${var.itype}"
}

module "staging" {
  source      = "./environment"
  providers   = {
    aws = "aws.staging"
  }
  account     = "${var.mgt_account}"
  region      = "${var.region}"
  itype       = "${var.itype}"
}

module "production" {
  source      = "./environment"
  providers   = {
    aws = "aws.production"
  }
  account     = "${var.mgt_account}"
  region      = "${var.region}"
  itype       = "${var.itype}"
}
