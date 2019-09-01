provider "aws" {
}

//--------------------------------------------------------------------
// Variables
variable "name" {}
variable "owner" {}
variable "environment_tag" {}
variable "vpc_name" {}
variable "vpc_enable_nat_gateway" {}
variable "vpc_one_nat_gateway_per_az" {}
variable "vpc_single_nat_gateway" {}

//--------------------------------------------------------------------
// Modules

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
  enable_dns_hostnames = true
  tags  = {
      owner = var.owner
      env   = var.environment_tag
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "${var.vpc_name}-rds-sg"
  description = "Security group for RDS EC2 instance and security group"
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

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

output "database_subnet_ids" {
  value = module.vpc.database_subnets
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
