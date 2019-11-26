####################### TAGS Reference############################ 
  
variable "appname" {
  default = "Blue"
}

variable "owner" {
  type = "string"
  default = "TEST"
}

variable "ZONE" {
  default     = "S01"
  description = "ZONE it belongs to as Management/Workspace.."
}

variable "envr" {
  default     = "T"
}



################################################################## 
variable "environment" {
  description = "Name of the environment"
  default = "TEST"
}

variable "aws_region" {
  description = "AWS region"
  default = ""
}

variable "security_groups"{
  default = ["",""]
}

variable "ecs_key_pair_name" {
  description = "EC2 instance key pair name"
  default = "test"
}

variable "customer" {
  default = "TEST"
}

variable "ecs_cluster" {
  description = "ECS cluster name"
  default = "BLUE"
}

variable "ecs_cluster_green"{
  default = "GREEN"
}

variable "vpc_id" {
  description = "VPC id for Test environment"
  default = "YOUR VPC ID"
}

variable "vpc_cidr" {
  description = "IP addressing for Test Network"
  default = "your vpc cidr"
}

variable "public_subnet_cidrs" {
  description = "Public 0.0 CIDR for externally accessible subnet"
  type = "list"
  default = ["your subnets", "your subnet"]
}


variable "public_subnets" {
  type = "list"
  default = ["YOUR PUBLIC SUBNET ","YOUR PUBLIC SUBNET"]
}

variable "public_subnets_efs" {
  default = "EFS SUBNETS"
}
# variable "private_subnets" {}

########################### Autoscale Config ################################

variable "max_instance_size" {
  description = "Maximum number of instances in the cluster"
  default = "3"
}

variable "min_instance_size" {
  description = "Minimum number of instances in the cluster"
  default = "1"
}

variable "desired_capacity" {
  description = "Desired number of instances in the cluster"
  default = "1"
}

variable "container_name" {
  default = "apache2"
}


# variable "domain_name" {
#   description = "Domain name of the Hosted Zone"
# }

# variable "role_arn" {
#   default = ""
#   description = "Role to manage ecs task scaling"
# }


#########################RDS My SQL ###########################

# variable "db_admin" {
#   default = ""
# }

# variable "db_password" {
#   default = ""
# }

# variable "db_instance_size" {
#   default = "db.t2.micro"
# }
