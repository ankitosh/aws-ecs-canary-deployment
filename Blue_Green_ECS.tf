resource "aws_ecs_cluster" "blue-cluster" {
    name = "${var.ecs_cluster}"
}


data "aws_ecs_task_definition" "apache2" {
task_definition = "${aws_ecs_task_definition.apache2.family}"
depends_on = ["aws_ecs_task_definition.apache2"]
}


resource "aws_ecs_task_definition" "apache2" {
family = "apache2"
container_definitions  = "${file("blue_task_definition.json")}"
  # volume {
  #   name      = "efs"
  #   host_path = "/efs/wordpress"
  # }

  volume {
      name      = "wordpress-vol"
      host_path = "/mnt/efs/wordpress"
    }
requires_compatibilities = ["EC2"]
network_mode            = "bridge"
}

resource "aws_ecs_service" "test-ecs-service" {
name = "Blue-${var.customer}-${var.appname}-${var.ZONE}-${var.envr}"
#name    = "${aws_ecs_service.ecs-service.name}"
cluster = "${aws_ecs_cluster.blue-cluster.id}"
task_definition = "${aws_ecs_task_definition.apache2.family}:${max("${aws_ecs_task_definition.apache2.revision}", "${data.aws_ecs_task_definition.apache2.revision}")}"
desired_count = 3
iam_role = "${aws_iam_role.ecs-service-role-1.name}"


deployment_controller {
  type = "CODE_DEPLOY"
  }

  # Un Comment this if you want to  Place tasks based on the least available amount of CPU or memory. 
  #This minimizes the number of instances in use.
  # ordered_placement_strategy {
  #   type  = "binpack"
  #   field = "cpu"
  # }


  ordered_placement_strategy {
    type  = "spread"
    field = "instanceId"
  }



load_balancer {
target_group_arn = "${aws_alb_target_group.blue-tg.arn}"
container_name = "${var.container_name}"
container_port = "80"
}

depends_on = [
  "aws_ecs_service.test-ecs-service",
  "aws_alb_listener.blue-listener"
  ]
}

resource "aws_appautoscaling_target" "main" {
  #count = "${ var.autoscale_iam_role_arn != "" ? 1 : 0 }"

  max_capacity       = "10"
  min_capacity       = "3"
  resource_id        = "service/${aws_ecs_cluster.blue-cluster.name}/${aws_ecs_service.test-ecs-service.name}"
  #resource_id        = "${aws_ecs_service.test-ecs-service.id}"
  role_arn           = "${aws_iam_role.ecs-service-role-1.arn}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

// Memory Utilization

resource "aws_appautoscaling_policy" "memory_high" {
  #count = "${ lookup(var.scale_out_thresholds, "memory", "") != "" ? 1 : 0 }"

  name               = "Blue-${var.customer}-${var.appname}-Service-${var.ZONE}-${var.envr}-scale_out-memory_utilization"
  resource_id        = "${aws_appautoscaling_target.main.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.main.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.main.service_namespace}"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = "300"
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = ["aws_appautoscaling_target.main"]
}

resource "aws_cloudwatch_metric_alarm" "memory_high" {
  #count = "${ lookup(var.scale_out_thresholds, "memory", "") != "" ? 1 : 0 }"

  alarm_name          = "Blue-${var.customer}-${var.appname}-Service-${var.ZONE}-${var.envr}-MemoryUtilization-High"
  alarm_description   = "scale-out pushed by memory-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "60"
  treat_missing_data  = "notBreaching"
  #ok_actions          = ["${compact(var.scale_out_ok_actions)}"]
  alarm_actions       = ["${aws_appautoscaling_policy.memory_high.arn}"]

  dimensions = {
    ClusterName = "${aws_ecs_cluster.blue-cluster.name}"
    ServiceName = "${aws_ecs_service.test-ecs-service.name}"
  }
}

resource "aws_appautoscaling_policy" "memory_low" {
 # count = "${ lookup(var.scale_in_thresholds, "memory", "") != "" ? 1 : 0 }"

  name               = "Blue-${var.customer}-${var.appname}-Service-${var.ZONE}-${var.envr}-scale_in-memory_utilization"
  resource_id        = "${aws_appautoscaling_target.main.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.main.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.main.service_namespace}"
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = "300"
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = ["aws_appautoscaling_target.main"]
}

resource "aws_cloudwatch_metric_alarm" "memory_low" {
  #count = "${ lookup(var.scale_in_thresholds, "memory", "") != "" ? 1 : 0 }"

  alarm_name          = "Blue-${var.customer}-${var.appname}-Service-${var.ZONE}-${var.envr}-MemoryUtilization-Low"
  alarm_description   = "scale-in pushed by memory-utilization"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "30"
  treat_missing_data  = "notBreaching"
  #ok_actions          = ["${compact(var.scale_in_ok_actions)}"]
  alarm_actions       = ["${aws_appautoscaling_policy.memory_low.arn}"]

  dimensions = {
    ClusterName = "${aws_ecs_cluster.blue-cluster.name}"
    ServiceName = "${aws_ecs_service.test-ecs-service.name}"
  }
}

// CPU Utilization

resource "aws_appautoscaling_policy" "cpu_high" {
# count = "${ lookup(var.scale_out_thresholds, "cpu", "") != "" ? 1 : 0 }"

  name               = "Blue-${var.customer}-${var.appname}-Service-${var.ZONE}-${var.envr}-scale_out-cpu_utilization"
  resource_id        = "${aws_appautoscaling_target.main.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.main.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.main.service_namespace}"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = "300"
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = ["aws_appautoscaling_target.main"]
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
#  count = "${ lookup(var.scale_out_thresholds, "cpu", "") != "" ? 1 : 0 }"

  alarm_name          = "Blue-${var.customer}-${var.appname}-Service-${var.ZONE}-${var.envr}-CPUUtilization-High"
  alarm_description   = "scale-out pushed by cpu-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "60"
  treat_missing_data  = "notBreaching"
  #ok_actions          = ["${compact(var.scale_out_ok_actions)}"]
  alarm_actions       = ["${aws_appautoscaling_policy.cpu_high.arn}"]

  dimensions = {
    ClusterName = "${aws_ecs_cluster.blue-cluster.name}"
    ServiceName = "${aws_ecs_service.test-ecs-service.name}"
  }
}

resource "aws_appautoscaling_policy" "cpu_low" {
  #count = "${ lookup(var.scale_in_thresholds, "cpu", "") != "" ? 1 : 0 }"

  name               = "Blue-${var.customer}-${var.appname}-Service-${var.ZONE}-${var.envr}-scale_in-cpu_utilization"
  resource_id        = "${aws_appautoscaling_target.main.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.main.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.main.service_namespace}"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = "300"
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = ["aws_appautoscaling_target.main"]
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
#  count = "${ lookup(var.scale_in_thresholds, "cpu", "") != "" ? 1 : 0 }"

  alarm_name          = "Blue-${var.customer}-${var.appname}-Service-${var.ZONE}-${var.envr}-CPUUtilization-Low"
  alarm_description   = "scale-in pushed by cpu-utilization"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "30"
  treat_missing_data  = "notBreaching"
  #ok_actions          = ["${compact(var.scale_in_ok_actions)}"]
  alarm_actions       = ["${aws_appautoscaling_policy.cpu_low.arn}"]

  dimensions = {
    ClusterName = "${aws_ecs_cluster.blue-cluster.name}"
    ServiceName = "${aws_ecs_service.test-ecs-service.name}"
  }
}
