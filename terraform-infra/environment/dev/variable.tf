variable "project_name" {
  description = "Name used as a prefix for all resources in this project"
  type        = string
  default     = "3-tier-app"
}

variable "environment" {
  description = "Deployment environment (dev, stage, prod). Drives resource naming and sizing."
  type        = string

  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "environment must be one of: dev, stage, prod."
  }
}

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-south-1"
}

#-------------------------- VPC ---------------------------------#
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones for the VPC"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks for the VPC"
  type        = list(string)
}

# private subnets for frontend, backend, and database tiers
variable "frontend_subnet_cidrs" {
  description = "List of frontend subnet CIDR blocks for the VPC"
  type        = list(string)
}

variable "backend_subnet_cidrs" {
  description = "List of backend subnet CIDR blocks for the VPC"
  type        = list(string)
}

variable "database_subnet_cidrs" {
  description = "List of datab  ase subnet CIDR blocks for the VPC"
  type        = list(string)
}

variable "single_nat_gateway" {
  description = "Whether to use a single NAT gateway (true) or multiple for high availability (false)"
  type        = bool
  default     = true
}

# ----------------------- Security Groups ----------------------------#
# variable "" {
  
# }


# -------------------------- RDS Database Variables -----------------------------------------
variable "db_engine" {
  description = "Database engine for RDS (e.g., mysql, postgres)"
  type        = string
}

variable "db_instance_class" {
  description = "Instance class for the RDS database"
  type        = string
}

variable "db_allocated_storage" {
  description = "Allocated storage (in GB) for the RDS database"
  type        = number
}

variable "db_engine_version" {
  description = "Engine version for the RDS database"
  type        = string
}

variable "db_name" {
  description = "Name of the RDS database"
  type        = string
}

variable "db_username" {
  description = "Username for the RDS database"
  type        = string
  default     = "admin"
}

variable "db_multi_az" {
  description = "Whether to enable Multi-AZ deployment for the RDS database"
  type        = bool
  default     = false
}

variable "db_backup_retention" {
  description = "Backup retention period (in days) for the RDS database"
  type        = number
  default     = 7
}

variable "db_skip_final_snapshot" {
  description = "Whether to skip the final snapshot when deleting the RDS database"
  type        = bool
  default     = true
}

 

# ------------------------- Autoscaling Group ---------------------------------#

variable "frontend_instance_type" {
  type = string
  description = "Ec2 - instance type"
  default = "t3.micro"
}

variable "frontend_min_size" {
  description = "Minimum number of instances in the ASG"
  type        = number
  default     = 1
}

variable "frontend_max_size" {
  description = "Maximum number of instances in the ASG"
  type        = number
  default     = 3
}

variable "frontend_desired_capacity" {
  description = "Desired number of instances in the ASG"
  type        = number
  default     = 2
}
variable "frontend_docker_image" {
   type = string
}

variable "backend_instance_type" {
  type = string
  description = "Ec2 - instance type"
  default = "t3.micro"
}

variable "backend_min_size" {
  description = "Minimum number of instances in the ASG"
  type        = number
  default     = 1
}

variable "backend_max_size" {
  description = "Maximum number of instances in the ASG"
  type        = number
  default     = 3
}

variable "backend_desired_capacity" {
  description = "Desired number of instances in the ASG"
  type        = number
  default     = 2
}


variable "backend_docker_image" {
  type = string
}

variable "dockerhub_username" {
  type = string
}

variable "dockerhub_password" {
   type = string
   sensitive = true
}

# --------------------------- tags ------------------------------------

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {
    Environment = "dev"
    Project     = "3-tier-app"
    ManagedBy   = "terraform"
    Owner       = "devops-team"
  }  
}

# ------------------------- Launch Template / AMI ---------------------------------#

variable "ami_name" {
  description = "Name (prefix, matched with a wildcard) of the golden-image AMI to launch instances from"
  type        = string
  default     = "Goldan image"
}

variable "instance_type" {
  description = "EC2 instance type for the launch template"
  type        = string
  default     = "t3.micro"
}
