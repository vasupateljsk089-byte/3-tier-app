# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = module.vpc.vpc_arn
}

# Public Subnets
output "public_subnet_ids" {
  description = "List of IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "public_subnet_cidrs" {
  description = "List of CIDR blocks of the public subnets"
  value       = module.vpc.public_subnet_cidrs
}

output "public_subnet_arns" {
  description = "List of ARNs of the public subnets"
  value       = module.vpc.public_subnet_arns
}

# Frontend Private Subnets
output "frontend_subnet_ids" {
  description = "List of IDs of the frontend private subnets"
  value       = module.vpc.frontend_subnet_ids
}

output "frontend_subnet_cidrs" {
  description = "List of CIDR blocks of the frontend private subnets"
  value       = module.vpc.frontend_subnet_cidrs
}

output "frontend_subnet_arns" {
  description = "List of ARNs of the frontend private subnets"
  value       = module.vpc.frontend_subnet_arns
}

# Backend Private Subnets
output "backend_subnet_ids" {
  description = "List of IDs of the backend private subnets"
  value       = module.vpc.backend_subnet_ids
}

output "backend_subnet_cidrs" {
  description = "List of CIDR blocks of the backend private subnets"
  value       = module.vpc.backend_subnet_cidrs
}

output "backend_subnet_arns" {
  description = "List of ARNs of the backend private subnets"
  value       = module.vpc.backend_subnet_arns
}

# Database Isolated Subnets

output "database_subnet_ids" {
  description = "List of IDs of the database isolated subnets"
  value       = module.vpc.database_subnet_ids
}

output "database_subnet_cidrs" {
  description = "List of CIDR blocks of the database isolated subnets"
  value       = module.vpc.database_subnet_cidrs
}

output "database_subnet_arns" {
  description = "List of ARNs of the database isolated subnets"
  value       = module.vpc.database_subnet_arns
}

# NAT Gateways / EIPs

output "nat_gateway_ids" {
  description = "List of IDs of the NAT Gateways (empty if NAT is disabled)"
  value       = module.vpc.nat_gateway_ids
}

output "nat_gateway_public_ips" {
  description = "List of public Elastic IPs attached to the NAT Gateways"
  value       = module.vpc.nat_gateway_public_ips
}

output "nat_eip_allocation_ids" {
  description = "List of Elastic IP allocation IDs used by the NAT Gateways"
  value       = module.vpc.nat_eip_allocation_ids
}

# Route Tables

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = module.vpc.public_route_table_id
}

output "private_route_table_ids" {
  description = "List of IDs of the shared private route table(s) used by frontend + backend subnets (empty if NAT is disabled)"
  value       = module.vpc.private_route_table_ids
}

output "database_route_table_id" {
  description = "ID of the isolated database route table (no internet route attached)"
  value       = module.vpc.database_route_table_id
}

# Availability Zones

output "availability_zones" {
  description = "List of Availability Zones used by this VPC"
  value       = module.vpc.availability_zones
}