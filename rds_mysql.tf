resource "aws_db_instance" "default" {
  allocated_storage = 20
  storage_type      = "gp2"
  engine            = "mysql"
  engine_version    = "5.7"

  #  instance_class       = "db.t2.micro"
  instance_class       = "${var.db_instance_size}"
  name                 = "${var.customer}-DB-${var.appname}-${var.ZONE}-${var.envr}"
  username             = "${var.db_admin}"
  password             = "${var.db_password}"
  parameter_group_name = "default.mysql5.7"
}
