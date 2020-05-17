variable "dbuser" {}
variable "dbpass" {}

resource "aws_db_instance" "db" {
  allocated_storage      = 20
  engine                 = "mariadb"
  instance_class         = "db.t2.micro"
  name                   = "mydb"
  username               = "${var.dbuser}"
  password               = "${var.dbpass}"
  skip_final_snapshot    = true
  vpc_security_group_ids = ["${aws_security_group.sg_rds.id}"]
}
