module "vpc" {
  source = "../../modules/vpc"

  environment           = var.environment
  project_name          = var.project_name
  vpc_cidr              = var.vpc_cidr
  availability_zones    = var.availability_zones
  public_subnet_cidrs   = var.public_subnet_cidrs
  frontend_subnet_cidrs = var.frontend_subnet_cidrs
  backend_subnet_cidrs  = var.backend_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  enable_nat_gateway    = true
  single_nat_gateway    = var.single_nat_gateway
  tags  = var.tags
}

module "security_groups" {
  source = "../../modules/security-groups"

  environment  = var.environment
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
  tags         = var.tags
}

module "iam" {
  source = "../../modules/iam"

  environment  = var.environment
  project_name = var.project_name
}

data "aws_acm_certificate" "app" {
  domain      = "app.vasubhalani.in"
  statuses    = ["ISSUED"]
  most_recent = true
}