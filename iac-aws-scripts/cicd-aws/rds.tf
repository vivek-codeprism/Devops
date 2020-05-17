variable "db_user" {
  default = ""
}

variable "db_pass" {
  default = ""
}

resource "aws_db_subnet_group" "group" {
  name        = "rds"
  description = "rds subnet group"
  subnet_ids  = ["${aws_subnet.subnet.*.id}"]
}

resource "aws_db_instance" "db" {
  allocated_storage       = "10"
  engine                  = "mariadb"
  engine_version          = "10.2.15"
  instance_class          = "db.t2.micro"
  username                = "${var.db_user}"
  password                = "${var.db_pass}"
  db_subnet_group_name    = "${aws_db_subnet_group.group.id}"
  vpc_security_group_ids  = ["${aws_security_group.rds.id}"]
  publicly_accessible     = true
  skip_final_snapshot     = true
  depends_on              = ["aws_internet_gateway.gw"]
  backup_retention_period = 3
  backup_window           = "01:00-02:00"
}

output "rds" {
  value = "${aws_db_instance.db.endpoint}"
}
