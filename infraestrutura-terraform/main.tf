provider "aws" {
  region = var.aws_region
}

locals {
  environment = terraform.workspace == "default" ? "dev" : terraform.workspace
}

module "vpc" {
  source = "./modules/vpc"

  project                 = var.project
  environment             = local.environment
  vpc_cidr_block          = var.vpc_cidr_block
  availability_zones      = var.availability_zones
  availability_zone_count = var.availability_zone_count
  subnet_newbits          = var.subnet_newbits
}