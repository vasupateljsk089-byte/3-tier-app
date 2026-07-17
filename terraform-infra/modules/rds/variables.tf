variable "environment" {
  description = "The environment name"
    type        = string
}

variable "project_name" {
  description = "The project name"
  type        = string
}

variable "subnet_ids" {
  description = "The IDs of the subnets"
  type        = list(string)
}

variable "tags" {
  description = "The tags for the resources"
  type        = map(string)
}


variable "engine" {
    description = "The database engine (e.g., postgres, mysql)"
    type        = string
}

variable "engine_version" {
    description = "The version of the database engine"
    type        = string
}

variable "instance_class" {
    description = "The instance class for the RDS instance"
    type        = string
}

variable "allocated_storage" {
    description = "The allocated storage in gigabytes"
    type        = number
}

variable "db_name" {
    description = "The name of the database"
    type        = string
}

variable "db_username" {
    description = "The username for the database"
    type        = string
}

variable "db_password" {
    description = "The password for the database"
    type        = string
    sensitive   = true
}

variable "security_group_id" {
    description = "The ID of the security group to associate with the RDS instance"
    type        = string
}

variable "multi_az" {
    description = "Whether to create a Multi-AZ RDS instance"
    type        = bool
    default     = false
}

variable "availability_zone" {
    description = "The availability zone for the RDS instance (if not Multi-AZ)"
    type        = string
    default     = null
}

variable "backup_retention_period" {
    description = "The number of days to retain backups"
    type        = number
    default     = 0
}

variable "skip_final_snapshot" {
    description = "Whether to skip the final snapshot when deleting the RDS instance"
    type        = bool
    default     = false
}

variable "monitoring_interval" {
    description = "Enhanced monitoring interval in seconds (0, 1, 5, 10, 15, 30, 60)"
    type        = number
    default     = 30
}

variable "deletion_protection" {
    description = "Whether to enable deletion protection for the RDS instance"
    type        = bool
    default     = false
}


