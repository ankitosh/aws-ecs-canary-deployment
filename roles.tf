resource "aws_iam_role" "ecs-service-role-1" {
  name               = "ecs-service-role-1"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.ecs-service-policy.json}"
}

resource "aws_iam_role_policy_attachment" "ecs-service-role-attachment" {
  role       = "${aws_iam_role.ecs-service-role-1.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

data "aws_iam_policy_document" "ecs-service-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs-instance-role-1" {
  name               = "ecs-instance-role-1"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.ecs-instance-policy.json}"
}

data "aws_iam_policy_document" "ecs-instance-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs-instance-role-attachment" {
  role       = "${aws_iam_role.ecs-instance-role-1.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs-instance-profile-1" {
  name = "ecs-instance-profile"
  path = "/"
  role = "${aws_iam_role.ecs-instance-role-1.id}"

  provisioner "local-exec" {
    command = "sleep 10"
  }
}

resource "aws_iam_role" "canary" {
  name               = "canary"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.canary-service-policy.json}"
}

resource "aws_iam_role_policy_attachment" "canary-service-role-attachment" {
  role       = "${aws_iam_role.ecs-service-role-1.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess"
}

data "aws_iam_policy_document" "canary-service-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}
