variable "instance_type" {}

variable "public_key" {
  default = "/dev/null"
}

variable "private_key" {
  default = "/dev/null"
}

variable "white_listed" {
  type = "list"
}

locals {
  repo = "https://github.com/demo_flask.git"
  yum  = "sudo yum -y -d 1 install"
  curl = "curl -sL"
}

resource "aws_key_pair" "key" {
  key_name   = "user"
  public_key = "${file(var.public_key)}"
}

data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "product-code"
    values = ["aw0evgkw8e5c1q413zgy5pjce"]

    # product-code is based on centos.org wiki
  }
}
