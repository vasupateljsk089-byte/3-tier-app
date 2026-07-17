variable "project_name" {
  description = "Name used as a prefix for all resources in this project"
  type        = string  
}

variable "environment" {
  description = "Deployment environment (dev, stage, prod). Drives resource naming and sizing."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones for the VPC"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks for the VPC"
  type        = list(string)
}

variable "frontend_subnet_cidrs" {
  description = "List of frontend subnet CIDR blocks for the VPC"
  type        = list(string)
}

variable "backend_subnet_cidrs" {
  description = "List of backend subnet CIDR blocks for the VPC"
  type        = list(string)
}

variable "database_subnet_cidrs" {
  description = "List of database subnet CIDR blocks for the VPC"
  type        = list(string)
}

variable "single_nat_gateway" {
  description = "Whether to use a single NAT gateway (true) or multiple for high availability (false)"
  type        = bool
  default     = true
}

variable "enable_nat_gateway" {
  description = "Whether to enable NAT gateway for private subnets"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}