variable "project_name" {
  description = "Name used as a prefix for all resources in this project"
  type        = string  
}

variable "environment" {
  description = "Deployment environment (dev, stage, prod). Drives resource naming and sizing."
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
}

variable "vpc_id" {
  description = "The ID of the VPC where the security groups will be created"
  type        = string
}
