# resource "aws_ecs_cluster" "green-cluster" {
#     name = "${var.ecs_cluster_green}"
# }

data "aws_ecs_task_definition" "apache2_green" {
task_definition = "${aws_ecs_task_definition.apache2_green.family}"
depends_on = ["aws_ecs_task_definition.apache2_green"]
}


resource "aws_ecs_task_definition" "apache2_green" {
family = "apache2_green"
container_definitions  = "${file("green_task_definition.json")}"
requires_compatibilities = ["EC2"]
network_mode            = "bridge"        
}


resource "aws_ecs_service" "ecs-service" {
name = "Green-${var.customer}-${var.appname}-Service-${var.ZONE}-${var.envr}"
cluster = "${aws_ecs_cluster.blue-cluster.id}"
task_definition = "${aws_ecs_task_definition.apache2_green.family}:${max("${aws_ecs_task_definition.apache2_green.revision}", "${data.aws_ecs_task_definition.apache2_green.revision}")}"
desired_count = 3
iam_role  = "${aws_iam_role.ecs-service-role-1.name}"
  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

/*
  ordered_placement_strategy {
    type  = "spread"
    field = "instanceId"
  }

*/

load_balancer {
target_group_arn = "${aws_alb_target_group.green-tg.arn}"
container_name = "apache2"
container_port = "80"
}
depends_on = ["aws_ecs_service.ecs-service"]
}

resource "aws_appautoscaling_target" "green" {
  #count = "${ var.autoscale_iam_role_arn != "" ? 1 : 0 }"

  max_capacity       = "10"
  min_capacity       = "3"
  resource_id        = "service/${aws_ecs_cluster.blue-cluster.name}/${aws_ecs_service.test-ecs-service.name}"
  role_arn           = "${aws_iam_role.ecs-service-role-1.arn}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  depends_on        = ["aws_ecs_service.test-ecs-service"]
  #depends_on        =      [${"aws_ecs_service.test-ecs-service.id "}]
}


// Memory Utilization

resource "aws_appautoscaling_policy" "memory_high_1" {
  #count = "${ lookup(var.scale_out_thresholds, "memory", "") != "" ? 1 : 0 }"

  name               = "Green-${var.customer}-${var.appname}-Service-${var.ZONE}-${var.envr}-scale_out-memory_utilization"
  resource_id        = "${aws_appautoscaling_target.green.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.green.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.green.service_namespace}"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = "300"
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = ["aws_appautoscaling_target.green"]
}

resource "aws_cloudwatch_metric_alarm" "memory_high_1" {
  #count = "${ lookup(var.scale_out_thresholds, "memory", "") != "" ? 1 : 0 }"

  alarm_name          = "Green-${var.customer}-${var.appname}-Service-${var.ZONE}-${var.envr}-MemoryUtilization-High"
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
  alarm_actions       = ["${aws_appautoscaling_policy.memory_high_1.arn}"]

  dimensions = {
    ClusterName = "${aws_ecs_cluster.blue-cluster.name}"
    ServiceName = "${aws_ecs_service.test-ecs-service.name}"
  }
}

resource "aws_appautoscaling_policy" "memory_low_1" {
 # count = "${ lookup(var.scale_in_thresholds, "memory", "") != "" ? 1 : 0 }"

  name               = "Green-${var.customer}-${var.appname}-Service-${var.ZONE}-${var.envr}-scale_in-memory_utilization"
  resource_id        = "${aws_appautoscaling_target.green.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.green.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.green.service_namespace}"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = "300"
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = ["aws_appautoscaling_target.green"]
}

resource "aws_cloudwatch_metric_alarm" "memory_low_1" {
  #count = "${ lookup(var.scale_in_thresholds, "memory", "") != "" ? 1 : 0 }"

  alarm_name          = "Green-${var.customer}-${var.appname}-Service-${var.ZONE}-${var.envr}-MemoryUtilization-Low"
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
  alarm_actions       = ["${aws_appautoscaling_policy.memory_low_1.arn}"]

  dimensions = {
    ClusterName = "${aws_ecs_cluster.blue-cluster.name}"
    ServiceName = "${aws_ecs_service.test-ecs-service.name}"
  }
}

// CPU Utilization

resource "aws_appautoscaling_policy" "cpu_high_1" {
# count = "${ lookup(var.scale_out_thresholds, "cpu", "") != "" ? 1 : 0 }"

  name               = "Green-${var.customer}-${var.appname}-Service-${var.ZONE}-${var.envr}-scale_out-cpu_utilization"
  resource_id        = "${aws_appautoscaling_target.green.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.green.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.green.service_namespace}"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = "300"
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = ["aws_appautoscaling_target.green"]
}

resource "aws_cloudwatch_metric_alarm" "cpu_high_1" {
#  count = "${ lookup(var.scale_out_thresholds, "cpu", "") != "" ? 1 : 0 }"

  alarm_name          = "Green-${var.customer}-${var.appname}-Service-${var.ZONE}-${var.envr}-CPUUtilization-High"
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
  alarm_actions       = ["${aws_appautoscaling_policy.cpu_high_1.arn}"]

  dimensions = {
    ClusterName = "${aws_ecs_cluster.blue-cluster.name}"
    ServiceName = "${aws_ecs_service.test-ecs-service.name}"
  }
}

resource "aws_appautoscaling_policy" "cpu_low_1" {
  #count = "${ lookup(var.scale_in_thresholds, "cpu", "") != "" ? 1 : 0 }"

  name               = "Green-${var.customer}-${var.appname}-Service-${var.ZONE}-${var.envr}-scale_in-cpu_utilization"
  resource_id        = "${aws_appautoscaling_target.green.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.green.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.green.service_namespace}"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = "300"
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = ["aws_appautoscaling_target.green"]
}

resource "aws_cloudwatch_metric_alarm" "cpu_low_1" {
#  count = "${ lookup(var.scale_in_thresholds, "cpu", "") != "" ? 1 : 0 }"

  alarm_name          = "Green-${var.customer}-${var.appname}-Service-${var.ZONE}-${var.envr}-CPUUtilization-Low"
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
  alarm_actions       = ["${aws_appautoscaling_policy.cpu_low_1.arn}"]

  dimensions = {
    ClusterName = "${aws_ecs_cluster.blue-cluster.name}"
    ServiceName = "${aws_ecs_service.test-ecs-service.name}"
  }
}