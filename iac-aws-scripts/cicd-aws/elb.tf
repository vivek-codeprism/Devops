resource "aws_elb" "scaling" {
  subnets         = ["${local.subnet}"]
  security_groups = ["${aws_security_group.elb.id}"]

  listener {
    instance_port     = 5000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 60
    target              = "HTTP:5000/static/css/style.css"
    interval            = 120
  }
}

output "elb" {
  value = "${aws_elb.scaling.dns_name}"
}
