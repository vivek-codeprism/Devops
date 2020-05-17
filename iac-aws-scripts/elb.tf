resource "aws_elb" "elb" {
  availability_zones = ["${aws_instance.api.availability_zone}"]
  listener {
    instance_port      = 5000
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "${aws_iam_server_certificate.cert.arn}"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:5000/"
    interval            = 30
  }
  instances = ["${aws_instance.api.id}"]
}
