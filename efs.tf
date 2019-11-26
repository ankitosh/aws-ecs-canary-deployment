resource "aws_efs_file_system" "wordpress-data" {
  creation_token = "es-persistent-data"
  performance_mode = "generalPurpose"

  tags = {
    Name = "EFS-${var.customer}-${var.appname}-${var.ZONE}-${var.envr}"
  }
}

resource "aws_efs_mount_target" "wordpress" {
  file_system_id = "${aws_efs_file_system.wordpress-data.id}"
  subnet_id      = "${var.public_subnets_efs}"
}
