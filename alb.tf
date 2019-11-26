
################################ Load Balancer Blue ###########################################
resource "aws_alb" "blue-lb" {
    name                = "Blue-${var.customer}-${var.appname}-${var.ZONE}-${var.envr}"
    security_groups     = "${var.security_groups}"
    subnets             = "${var.public_subnets}"

    tags = {
      Name = "Blue-${var.customer}-${var.appname}-${var.ZONE}-${var.envr}"
    }
}


################################# Target Group For Blue Deployment ###############################
resource "aws_alb_target_group" "blue-tg" {
    name                = "Blue-${var.customer}-${var.appname}-${var.ZONE}-${var.envr}"
    port                = "80"
    protocol            = "HTTP"
    vpc_id              = "${var.vpc_id}"

    health_check {
        healthy_threshold   = "5"
        unhealthy_threshold = "2"
        interval            = "30"
        matcher             = "200-499"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = "5"
    }

    tags = {
      Name = "Blue-${var.customer}-${var.appname}-${var.ZONE}-${var.envr}"
    }
}

resource "aws_alb_listener" "blue-listener" {
    load_balancer_arn = "${aws_alb.blue-lb.arn}"
    port              = "80"
    protocol          = "HTTP"

    default_action {
        target_group_arn = "${aws_alb_target_group.blue-tg.arn}"
        type             = "forward"
    }
    depends_on = [
        "aws_alb.blue-lb",
    ]


}

output "Blue-tg-arn" {
  value = "${aws_alb_target_group.blue-tg.arn}"
}


# ############################################## Target Group for Green Deployment #######################
resource "aws_alb_target_group" "green-tg" {
    name                = "Green-${var.customer}-${var.appname}-${var.ZONE}-${var.envr}"
    port                = "80"
    protocol            = "HTTP"
    vpc_id              = "${var.vpc_id}"

    health_check {
        healthy_threshold   = "5"
        unhealthy_threshold = "2"
        interval            = "30"
        matcher             = "200-399"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = "5"
    }

    tags = {
      Name = "Green-${var.customer}-${var.appname}-${var.ZONE}-${var.envr}"
    }
}

resource "aws_alb_listener" "green-listener" {
    load_balancer_arn = "${aws_alb.blue-lb.arn}"
    port              = "8080"
    protocol          = "HTTP"

    default_action {
        target_group_arn = "${aws_alb_target_group.green-tg.arn}"
        type             = "forward"
    }

    depends_on = [
        "aws_alb.blue-lb",
    ]
}
