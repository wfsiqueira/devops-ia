provider "aws" {
  region = var.aws_region
}

locals {
  environment = terraform.workspace == "default" ? "dev" : terraform.workspace
}

module "vpc" {
  source = "../../modules/vpc"

  project                 = var.project
  environment             = local.environment
  vpc_cidr_block          = var.vpc_cidr_block
  availability_zone_count = var.availability_zone_count
}

module "rds" {
  source = "../../modules/rds"

  project     = var.project
  environment = local.environment

  vpc_id     = module.vpc.vpc_id
  subnet_ids = values(module.vpc.subnet_private_ids)

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class
  db_name        = var.db_name

  multi_az                = var.multi_az
  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot

  allowed_cidr_blocks = [var.vpc_cidr_block]
}
