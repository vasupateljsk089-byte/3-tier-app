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

variable "db_username" {
  description = "The username for the database"
  type        = string
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}

variable "db_host" {
  description = "The hostname of the database"
  type        = string
}

variable "db_port" {
  description = "The port of the database"
  type        = number
}

variable "db_name" {
  description = "The name of the database"
  type        = string
}

variable "recovery_window_in_days" {
  description = "The number of days that Secrets Manager waits before it can delete the secret. Default is 30 days."
  type        = number
  default     = 0 
}