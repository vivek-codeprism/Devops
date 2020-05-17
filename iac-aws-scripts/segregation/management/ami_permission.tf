variable "ami_id" {}
variable "account" {
  type = "map"
}

resource "aws_ami_launch_permission" "ami_permission" {
  count      = "${length(var.account)}"
  image_id   = "${var.ami_id}"
  account_id = "${element(values(var.account), count.index)}"
}
