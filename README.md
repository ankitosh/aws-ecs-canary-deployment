# AWS ECS CANARY
## Highly Available Website

# About this Project
This Project creates Highly Avaialable *WORDPRESS* website where MySQl DB is *RDS* and Persistent Storage using *EFS*.

![AWS-HA-ARCHITECTURE](/template/aws-ha-wp.png)

### This Project Demonstrate AWS ECS Canary Deployment 
#### What is Canary Deployment ?
-  Well ! not much of an expert, a very basic explanation is that **CANARY**  deployment strategy is a new version of the Software can be deployed for the Testing Purpose and Current Version remains deployed as production release for Normal operations on the stage.

- By keeping canary traffic small and the selection random, most users are not adversely affected at any time by potential bugs in the new version, and no single user is adversely affected all the time.
- After the test metrics pass your requirements, you can promote the canary release to the production release and disable the canary from the deployment. This makes the new features available in the production stage.

Find more info at [AWS Documentation](https://docs.aws.amazon.com/apigateway/latest/developerguide/canary-release.html)

# We will create following resources
- Application Load Balancer  *alb.tf*
- AutoScaling Group with Max 3 Instance and Min 1 Instance *asg.tf*
- Blue ECS Cluster Group for our Blue means Production release worklaod  *Blue_ECS.tf*
- Task definition for the Blue ECS Service *blue_task_definition.json*
- Green ECS Cluster Group for our Green means Production release worklaod  *Green_ECS.tf*
- Task definition for the Blue ECS Service *green_task_definition.json*
- Deployment Controller for cananry deployment *deployment_group.tf*
- Elastic File System to store persistent data *efs.tf*
- Launch Configuration *lc.tf*
- RDS MySql Database for high avaialbility of DB *rds_mysql.tf*
- Roles required to manage the ECS Task Scaling *roles.tf*
- Route 53 to manage the DNS routing *route53.tf*
- Virtual Private Cloud VPC for our workload *vpc.tf*
- All the variables are stored in *variables.tf* for Generic Deployment.


### How to Use.
1. Clone Current Repository.
   - `git clone https://github.com/ankitosh/aws-ecs-canary-deployment.git` 
2. Create config.tf file with below below details 
    ***
        data "aws_caller_identity" "current" {}

        provider "aws" {
        region = "${var.aws_region}"
        }

        terraform {
        backend "s3" {
            bucket = "Your S3 Bucket Name"
            key    = "Your File Name.tfstate"
            region = "region of choice"
        }
        }
    ***


