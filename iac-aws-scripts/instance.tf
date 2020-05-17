variable "public_key_path" {}
variable "private_key_path" {}
variable "ami_id" {}
variable "itype" {}

resource "aws_security_group" "sg_api" {
  name        = "api"
  description = "access to api instance"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_rds" {
  name        = "rds"
  description = "access to rds instance"
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.sg_api.id}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "auth_api" {
  key_name   = "api-cred"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "api" {
  count           = 1
  ami             = "${var.ami_id}"
  instance_type   = "${var.itype}"
  key_name        = "${aws_key_pair.auth_api.id}"
  security_groups = ["api"]
}

output "ip" {
  value = "${aws_instance.api.public_ip}"
}
