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

resource "random_password" "db_password" {
  length  = 16
  special = true
  # Exclude characters that might cause issues in connection strings
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

module "secrets" {
  source = "../../modules/secrets"

  environment  = var.environment
  project_name = var.project_name
  db_username  = var.db_username
  db_password  = random_password.db_password.result
  db_host  = module.rds.db_address
  db_port  = module.rds.db_port
  db_name  = var.db_name

  tags = var.tags
}

# RDS Module
module "rds" {
  source = "../../modules/rds"

  environment             = var.environment
  engine                 = var.db_engine
  project_name            = var.project_name
  subnet_ids              = module.vpc.database_subnet_ids
  security_group_id       = module.security_groups.database_sg_id
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  engine_version          = var.db_engine_version
  db_name                 = var.db_name
  db_username             = var.db_username
  db_password             = random_password.db_password.result
  multi_az                = var.db_multi_az
  backup_retention_period = var.db_backup_retention
  skip_final_snapshot     = var.db_skip_final_snapshot

  tags = var.tags
}
# target group for backend
resource "aws_lb_target_group" "backend" {

  name     = "${var.environment}-${var.project_name}-backend-tg"

  port     = 4000
  protocol = "HTTP"

  vpc_id = module.vpc.vpc_id

  health_check {

    enabled = true
    path = "/api/health"
    port = "traffic-port"
    protocol = "HTTP"
    healthy_threshold = 2
    unhealthy_threshold = 3
    timeout = 5
    interval = 30
    matcher = "200-299"
  }

  deregistration_delay = 30
   
  tags = var.tags
}

# Public Application Load Balancer Module (Frontend) http => https
module "alb" {
  source = "../../modules/alb"

  environment       = var.environment
  project_name      = var.project_name

  name_prefix       = "public-"
  internal          = false

  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.public_subnet_ids
  security_group_id = module.security_groups.external_alb_sg_id

  enable_https_redirect = true
  certificate_arn       = data.aws_acm_certificate.app.arn

  target_group_port = 3000
  health_check_path = "/"

  backend_target_group_arn = aws_lb_target_group.backend.arn

  tags = var.tags
}

module "sns" {
  source = "../../modules/sns"

  environment  = var.environment
  project_name = var.project_name
  email        = "email@gmail.com"
}

module "frontend_asg" {
  source = "../../modules/frontend-asg"

  environment          = var.environment
  project_name        = var.project_name
  region               = var.aws_region
  instance_type        = var.frontend_instance_type
  # key_name             = var.ssh_key_name
  iam_instance_profile = module.iam.ec2_instance_profile_name
  security_group_id    = module.security_groups.frontend_sg_id
  subnet_ids           = module.vpc.frontend_subnet_ids
  target_group_arn     = module.alb.target_group_arn
  min_size             = var.frontend_min_size
  max_size             = var.frontend_max_size
  desired_capacity     = var.frontend_desired_capacity

  docker_image         = var.frontend_docker_image
  dockerhub_username   = var.dockerhub_username
  dockerhub_password   = var.dockerhub_password
  # backend_internal_url = "http://${module.internal_alb.alb_dns_name}"

  alarm_actions = [
    module.sns.topic_arn
  ]

  tags = var.tags

  depends_on = [module.rds, module.alb]
}

# Backend ASG Module
module "backend_asg" {
  source = "../../modules/backend-asg"

  environment          = var.environment
  project_name        = var.project_name
  region               = var.aws_region
  instance_type        = var.backend_instance_type
  # key_name             = var.ssh_key_name
  iam_instance_profile = module.iam.ec2_instance_profile_name
  security_group_id    = module.security_groups.backend_sg_id
  subnet_ids           = module.vpc.backend_subnet_ids
  target_group_arns    = [aws_lb_target_group.backend.arn]
  min_size             = var.backend_min_size
  max_size             = var.backend_max_size
  desired_capacity     = var.backend_desired_capacity

  docker_image       = var.backend_docker_image
  dockerhub_username = var.dockerhub_username
  dockerhub_password = var.dockerhub_password
  db_secret_arn      = module.secrets.db_secret_arn

  alarm_actions = [
    module.sns.topic_arn
  ]

  tags = var.tags

  depends_on = [module.rds, module.secrets]
}