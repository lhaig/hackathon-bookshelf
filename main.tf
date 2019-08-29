provider "aws" {
}

//--------------------------------------------------------------------
// Variables
variable "name" {}
variable "owner" {}
variable "environment_tag" {}
variable "rds_database_name" {}
variable "rds_database_password" {}
variable "rds_database_user" {}
variable "rds_identifier" {}
variable "rds_backup_window" {}
variable "rds_engine" {}
variable "rds_engine_version" {}
variable "rds_family" {}
variable "rds_iam_database_authentication_enabled" {}
variable "rds_instance_class" {}
variable "rds_maintenance_window" {}
variable "rds_major_engine_version" {}
variable "rds_port" {}
variable "vpc_name" {}
variable "vpc_enable_nat_gateway" {}
variable "vpc_one_nat_gateway_per_az" {}
variable "vpc_single_nat_gateway" {}

//--------------------------------------------------------------------
// Modules

# module "rds" {
#   source  = "terraform-aws-modules/rds/aws"
#   version = "2.5.0"

#   allocated_storage = 5
#   backup_window = var.rds_backup_window
#   engine = var.rds_engine
#   engine_version = var.rds_engine_version
#   family = var.rds_family
#   iam_database_authentication_enabled = var.rds_iam_database_authentication_enabled
#   identifier = var.rds_identifier
#   instance_class = var.rds_instance_class
#   maintenance_window = var.rds_maintenance_window
#   major_engine_version = var.rds_major_engine_version
#   name = var.rds_database_name
#   password = var.rds_database_password
#   port = var.rds_port
#   subnet_ids = module.vpc.database_subnets
#   username = var.rds_database_name
#   tags  = {
#       owner = var.owner
#       env   = var.environment_tag
#   }
# }

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.9.0"

  azs = ["eu-central-1a", "eu-central-1b"]
  cidr = "10.0.0.0/16"
  database_subnets = ["10.0.21.0/24", "10.0.22.0/24"]
  private_subnets = ["10.0.0.0/24", "10.0.32.0/24"]
  enable_nat_gateway = var.vpc_enable_nat_gateway
  name = var.vpc_name
  one_nat_gateway_per_az = var.vpc_one_nat_gateway_per_az
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
  single_nat_gateway = var.vpc_single_nat_gateway
  tags  = {
      owner = var.owner
      env   = var.environment_tag
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "${var.vpc_name}-rds-sg"
  description = "Security group for RDS EC2 instance"
  vpc_id      = module.vpc.vpc_id
  
  ingress_cidr_blocks  = ["10.0.0.0/24", "10.0.32.0/24"]
  ingress_rules            = ["https-443-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "MariaDB"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

output "security_group" {
  value = module.security_group.this_security_group_id
}

output "service_endpoint" {
  value = module.rds.this_db_instance_endpoint
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

output "database_subnet_ids" {
  value = module.vpc.database_subnets
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}