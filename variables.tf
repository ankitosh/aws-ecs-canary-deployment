####################### TAGS Reference############################ 

variable "appname" {
  default = "BLUE"
}

variable "owner" {
  type    = "string"
  default = "ANKIT"
}

variable "ZONE" {
  default     = "S01"
  description = "ZONE it belongs to as Management/Workspace.."
}

variable "envr" {
  default = "T"
}

################################################################## 
variable "environment" {
  description = "Name of the environment"
  default     = "TEST"
}

variable "aws_region" {
  description = "AWS region"
  default     = ""
}

variable "ecs_key_pair_name" {
  description = "EC2 instance key pair name"
  default     = ""
}

variable "customer" {
  default = "TEST"
}

variable "ecs_cluster" {
  description = "ECS cluster name"
  default     = "BLUE"
}

variable "ecs_cluster_green" {
  default = "GREEN"
}

variable "vpc_cidr" {
  description = "VPC CIDR for Test environment"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public 0.0 CIDR for externally accessible subnet"
  type        = "list"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidr" {
  default = ["10.0.5.0/24", "10.0.6.0/24"]
}

variable "az" {
  default = ["eu-west-1a", "eu-west-1b"]
}

########################### Autoscale Config ################################

variable "max_instance_size" {
  description = "Maximum number of instances in the cluster"
  default     = "3"
}

variable "min_instance_size" {
  description = "Minimum number of instances in the cluster"
  default     = "1"
}

variable "desired_capacity" {
  description = "Desired number of instances in the cluster"
  default     = "1"
}

variable "container_name" {
  default = "apache2"
}


#########################RDS My SQL ###########################


variable "db_admin" {
  default = ""
}


variable "db_password" {
  default = ""
}


variable "db_instance_size" {
  default = "db.t2.micro"
}

variable "domain_name" {
  default = ""
}