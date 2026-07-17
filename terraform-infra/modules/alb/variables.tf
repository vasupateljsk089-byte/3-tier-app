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

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}


variable "security_group_id" {
  description = "The ID of the security group to associate with the ALB"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for naming the ALB and target group"
  type        = string
}

variable "internal" {
  description = "Whether the ALB is internal or internet-facing"
  type        = bool
}

variable "target_group_port" {
  description = "The port on which the target group is listening"
  type        = number
}

variable "enable_deletion_protection" {
  description = "Whether to enable deletion protection for the ALB"
  type        = bool
  default     = false
}


variable "health_check_path" {
  description = "Health check path for target group"
  type        = string
  default     = "/"
}

variable "enable_https_redirect" {
  description = "If true, port 80 redirects to 443. If false, port 80 forwards to target group."
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "ACM cert ARN. Leave empty to skip creating the 443 listener entirely."
  type        = string
  default     = ""
}

variable "backend_target_group_arn" {
  type = string
  default = null
}