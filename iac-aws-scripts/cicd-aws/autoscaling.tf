variable "docker_id" {}
variable "version" {}
variable "scale_factor" {}

variable "mysql_host" {
  default = "localhost"
}

variable "elk" {
  default = "127.0.0.1"
}

data "template_file" "user_data" {
  template = "${file("user_data.tpl")}"

  vars {
    yum        = "${local.yum}"
    docker_id  = "${var.docker_id}"
    version    = "${var.version}"
    mysql_host = "${var.mysql_host}"
    elk        = "${var.elk}"
  }
}

resource "aws_launch_configuration" "launch" {
  image_id                    = "${data.aws_ami.ami.image_id}"
  instance_type               = "${var.instance_type}"
  associate_public_ip_address = true
  user_data                   = "${data.template_file.user_data.rendered}"
  security_groups             = ["${aws_security_group.app.id}"]
}

resource "aws_autoscaling_group" "scaling" {
  name                 = "asg-${aws_launch_configuration.launch.name}"
  vpc_zone_identifier  = ["${local.subnet}"]
  launch_configuration = "${aws_launch_configuration.launch.name}"
  load_balancers       = ["${aws_elb.scaling.name}"]
  min_size             = "${var.scale_factor}"
  max_size             = "${var.scale_factor}"
  depends_on           = ["aws_route.route"]

  tag {
    key                 = "Name"
    value               = "app-asg"
    propagate_at_launch = true
  }
}
