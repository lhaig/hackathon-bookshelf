provider "aws" {
}

//--------------------------------------------------------------------
// Variables
variable "name" {}
variable "owner" {}
variable "environment_tag" {}
variable "rds_backup_window" {}
variable "rds_engine" {}
variable "rds_engine_version" {}
variable "rds_family" {}
variable "rds_iam_database_authentication_enabled" {}
variable "rds_instance_class" {}
variable "rds_maintenance_window" {}
variable "rds_major_engine_version" {}
variable "rds_port" {}
variable "vpc_enable_nat_gateway" {}
variable "vpc_one_nat_gateway_per_az" {}
variable "vpc_single_nat_gateway" {}

//--------------------------------------------------------------------
// Modules

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "2.5.0"

  allocated_storage = 5
  backup_window = var.rds_backup_window
  engine = var.rds_engine
  engine_version = var.rds_engine_version
  family = var.rds_family
  iam_database_authentication_enabled = var.rds_iam_database_authentication_enabled
  identifier = "demodb"
  instance_class = var.rds_instance_class
  maintenance_window = var.rds_maintenance_window
  major_engine_version = var.rds_major_engine_version
  name = "demodb"
  password = "foobarpw123"
  port = var.rds_port
  subnet_ids = [module.vpc.database_subnets.ids]
  username = "user"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.9.0"

  azs = ["eu-central-1a", "eu-central-1b"]
  cidr = "10.0.0.0/16"
  database_subnets = ["10.0.21.0/24", "10.0.22.0/24"]
  enable_nat_gateway = var.vpc_enable_nat_gateway
  name = "my-vpc"
  one_nat_gateway_per_az = var.vpc_one_nat_gateway_per_az
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
  single_nat_gateway = var.vpc_single_nat_gateway
  tags  = {
      owner = var.owner
      env = var.environment_tag
  }
}