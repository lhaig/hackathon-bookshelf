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

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "2.5.0"

  allocated_storage = 5
  backup_window = var.rds_backup_window
  engine = var.rds_engine
  engine_version = var.rds_engine_version
  family = var.rds_family
  iam_database_authentication_enabled = var.rds_iam_database_authentication_enabled
  identifier = var.rds_identifier
  instance_class = var.rds_instance_class
  maintenance_window = var.rds_maintenance_window
  major_engine_version = var.rds_major_engine_version
  name = var.rds_database_name
  password = var.rds_database_password
  port = var.rds_port
  subnet_ids = module.vpc.database_subnets
  username = var.rds_database_name
  tags  = {
      owner = var.owner
      env   = var.environment_tag
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.9.0"

  azs = ["eu-central-1a", "eu-central-1b"]
  cidr = "10.0.0.0/16"
  database_subnets = ["10.0.21.0/24", "10.0.22.0/24"]
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

# data "aws_ami" "amazon_linux" {
#   most_recent = true
#   owners = ["amazon"]
#   filter {
#     name = "name"
#     values = [
#       "amzn-ami-hvm-*-x86_64-gp2",
#     ]
#   }

#   filter {
#     name = "owner-alias"
#     values = [
#       "amazon",
#     ]
#   }
# }

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "${var.vpc_name}-sg"
  description = "Security group for web EC2 instance"
  vpc_id      = module.vcp.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
}

# resource "aws_eip" "this" {
#   vpc      = true
#   instance = module.ec2_instance.id[0]
# }

# module "ec2_instance" {
#   source  = "terraform-aws-modules/ec2-instance/aws"
#   version = "2.8.0"
#   name          = "${var.vpc_name}-web"
#   ami           = data.aws_ami.amazon_linux.id
#   instance_type = "c5.large"
#   subnet_id     = tolist(data.aws_subnet_ids.all.ids)[0]
#   vpc_security_group_ids      = module.security_group.this_security_group_id
#   associate_public_ip_address = true

#   tags  = {
#       owner = var.owner
#       env   = var.environment_tag
#   }
# }