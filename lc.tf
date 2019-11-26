# data "aws_ssm_parameter" "ecs-optimized"{
#   name = "/GoldenAMI/ECS-Linux/Amazon-Linux/source"
# }

data "template_file" "cloud_config" {
  template = "${file("${path.module}/template/cloud-config.sh")}"
  vars = {
    aws_region  = "${var.aws_region}"
    ecs_cluster = "${aws_ecs_cluster.blue-cluster.name}"
    efs_id      = "${aws_efs_file_system.wordpress-data.id}"
  }
}


resource "aws_launch_configuration" "ecs-launch-configuration" {
    name                        = "${var.ecs_cluster}-${var.customer}-LC-${var.appname}-${var.ZONE}-${var.envr}-Deployment"
    image_id                    = "ami-0261c46ac16f4cf12"
    #image_id                    = "${data.aws_ssm_parameter.ecs-optimized.value}"
    instance_type               = "t2.medium"
    iam_instance_profile        = "${aws_iam_role.ecs-instance-role-1.name}"

    root_block_device {
      volume_type = "standard"
      volume_size = 30
      delete_on_termination = true
    }

    lifecycle {
      create_before_destroy = true
    }

    security_groups             = "${var.security_groups}"
    associate_public_ip_address = "true"
    key_name                    = "${var.ecs_key_pair_name}"
    user_data                   = "${data.template_file.cloud_config.rendered}"
    # user_data                   = <<EOF
    #                               #!/bin/bash
    #                               echo ECS_CLUSTER=${var.ecs_cluster} >> /etc/ecs/ecs.config
    #                               EOF
}


resource "aws_launch_configuration" "ecs-launch-configuration_2" {
    name                        = "Green-${var.ecs_cluster_green}-${var.customer}-LC-${var.appname}-${var.ZONE}-${var.envr}-Deployment"
    image_id                    = "ami-04a084a6d17d9816e"
    #image_id                    = "${data.aws_ssm_parameter.ecs-optimized.value}"
    instance_type               = "t2.medium"
    iam_instance_profile        = "${aws_iam_role.ecs-instance-role-1.name}"

    root_block_device {
      volume_type = "standard"
      volume_size = 30
      delete_on_termination = true
    }

    lifecycle {
      create_before_destroy = true
    }

    security_groups             ="${var.security_groups}"
    associate_public_ip_address = "true"
    key_name                    = "${var.ecs_key_pair_name}"
    user_data                   = <<EOF
                                  #!/bin/bash
                                  echo ECS_CLUSTER=${var.ecs_cluster_green} >> /etc/ecs/ecs.config
                                  EOF
}


