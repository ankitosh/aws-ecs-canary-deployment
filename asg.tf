resource "aws_autoscaling_group" "blue-asg" {
    name                        = "Blue-${var.ecs_cluster}-${var.customer}-${var.appname}-${var.ZONE}-${var.envr}"
    max_size                    = "${var.max_instance_size}"
    min_size                    = "${var.min_instance_size}"
    desired_capacity            = "${var.desired_capacity}"
    vpc_zone_identifier         = "${var.public_subnets}"
    launch_configuration        = "${aws_launch_configuration.ecs-launch-configuration.name}"
  
  tags = [
    {
      key   = "Name"
      value = "Blue-${var.ecs_cluster}-${var.customer}-${var.appname}-${var.ZONE}-${var.envr}"
      propagate_at_launch = true
    },
    {
      key                 = "Application"
      value               = "GENERIC_UNSPECIFIED"
      propagate_at_launch = true
    },
    {
      key                 = "Patch_Group"
      value               = "Linux_Patch_Group_1"
      propagate_at_launch = true
    } 
  ]
}
  

resource "aws_autoscaling_attachment" "attach_tg" {
  autoscaling_group_name = "${aws_autoscaling_group.blue-asg.name}"
  alb_target_group_arn   = "${aws_alb_target_group.blue-tg.arn}"
}


resource "aws_autoscaling_policy" "scale_up" {
  name                  = "Blue-${var.ecs_cluster}-${var.customer}-ASG-${var.appname}-${var.ZONE}-${var.envr}-SCALE-UP"
  #name                   = "${var.product}-${var.environment}${var.sub_environment == "" ? "" : "-${var.sub_environment}"}-scaleup"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.blue-asg.name}"

 

  lifecycle {
    create_before_destroy = true
  }
}

 

resource "aws_autoscaling_policy" "scale_down" {
  #name                   = "${var.product}-${var.environment}${var.sub_environment == "" ? "" : "-${var.sub_environment}"}-scaledown"
  name                    = "Blue-${var.ecs_cluster}-${var.customer}-${var.appname}-${var.ZONE}-${var.envr}-SCALE-DOWN"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.blue-asg.name}"

 

  lifecycle {
    create_before_destroy = true
  }
}

######################### ECS Nodes Scale up & Scale Down################3

resource "aws_cloudwatch_metric_alarm" "cpu_high_ec2" {
  #alarm_name          = "${var.product}-${var.environment}${var.sub_environment == "" ? "" : "-${var.sub_environment}"} - high-cpu"
  alarm_name          = "Blue-${var.ecs_cluster}-${var.customer}-${var.appname}-${var.ZONE}-${var.envr}-CPU-HIGH"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "60"
  treat_missing_data  = "breaching"

 

  dimensions = {
    ClusterName = "${aws_ecs_cluster.blue-cluster.name}"
  }

 

  alarm_description = "Scale up if the cpu Utilization is above 60% for 1 minute"
  alarm_actions     = ["${aws_autoscaling_policy.scale_up.arn}"]

 

  lifecycle {
    create_before_destroy = true
  }
}

 

resource "aws_cloudwatch_metric_alarm" "memory_high_ec2" {
 #$ alarm_name          = "${var.product}-${var.environment}${var.sub_environment == "" ? "" : "-${var.sub_environment}"} - high-memory"
  alarm_name          = "Blue-${var.ecs_cluster}-${var.customer}-${var.appname}-${var.ZONE}-${var.envr}-MEMORY-HIGH"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "60"
  treat_missing_data  = "breaching"
 

  dimensions = {
    ClusterName = "${aws_ecs_cluster.blue-cluster.name}"
  }

 

  alarm_description = "Scale up if the memory Utilization is above 60% for 1 minute"
  alarm_actions     = ["${aws_autoscaling_policy.scale_up.arn}"]

 

  lifecycle {
    create_before_destroy = true
  }

 
  # This is required to make cloudwatch alarms creation sequential, AWS doesn't
  # support modifying alarms concurrently.
  depends_on = ["aws_cloudwatch_metric_alarm.cpu_high_ec2"]
}

 

resource "aws_cloudwatch_metric_alarm" "cpu_low_ec2" {
  #alarm_name          = "${var.product}-${var.environment}${var.sub_environment == "" ? "" : "-${var.sub_environment}"} - low-cpu-Utilization"
  alarm_name          = "Blue-${var.ecs_cluster}-${var.customer}-${var.appname}-${var.ZONE}-${var.envr}-CPU-LOW"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "30"
  treat_missing_data  = "breaching"
 

  dimensions = {
    ClusterName = "${aws_ecs_cluster.blue-cluster.name}"
  }

 

  alarm_description = "Scale down if the cpu Utilization is below 30% for 1 minute"
  alarm_actions     = ["${aws_autoscaling_policy.scale_down.arn}"]

 

  lifecycle {
    create_before_destroy = true
  }

 

  # This is required to make cloudwatch alarms creation sequential, AWS doesn't
  # support modifying alarms concurrently.
  depends_on = ["aws_cloudwatch_metric_alarm.memory_high_ec2"]
}

 

resource "aws_cloudwatch_metric_alarm" "memory_low_ec2" {
  #alarm_name          = "${var.product}-${var.environment}${var.sub_environment == "" ? "" : "-${var.sub_environment}"} - low-memory-Utilization"
  alarm_name          = "Blue-${var.ecs_cluster}-${var.customer}-${var.appname}-${var.ZONE}-${var.envr}-MEMORY-LOW"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "30"
  treat_missing_data  = "breaching"
 

  dimensions = {
    ClusterName = "${aws_ecs_cluster.blue-cluster.name}"
  }

 

  alarm_description = "Scale down if the memory Utilization is below 30% for 1 minute"
  alarm_actions     = ["${aws_autoscaling_policy.scale_down.arn}"]

 

  lifecycle {
    create_before_destroy = true
  }

 

  # This is required to make cloudwatch alarms creation sequential, AWS doesn't
  # support modifying alarms concurrently.
  depends_on = ["aws_cloudwatch_metric_alarm.cpu_low_ec2"]
}

