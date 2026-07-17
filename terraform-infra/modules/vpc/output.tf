output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = aws_vpc.main.arn
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "public_subnet_ids" {
  description = "List of IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "public_subnet_cidrs" {
  description = "List of CIDR blocks of the public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "public_subnet_arns" {
  description = "List of ARNs of the public subnets"
  value       = aws_subnet.public[*].arn
}

output "frontend_subnet_ids" {
  description = "List of IDs of the frontend private subnets"
  value       = aws_subnet.frontend[*].id
}

output "frontend_subnet_cidrs" {
  description = "List of CIDR blocks of the frontend private subnets"
  value       = aws_subnet.frontend[*].cidr_block
}

output "frontend_subnet_arns" {
  description = "List of ARNs of the frontend private subnets"
  value       = aws_subnet.frontend[*].arn
}

output "backend_subnet_ids" {
  description = "List of IDs of the backend private subnets"
  value       = aws_subnet.backend[*].id
}

output "backend_subnet_cidrs" {
  description = "List of CIDR blocks of the backend private subnets"
  value       = aws_subnet.backend[*].cidr_block
}

output "backend_subnet_arns" {
  description = "List of ARNs of the backend private subnets"
  value       = aws_subnet.backend[*].arn
}

output "database_subnet_ids" {
  description = "List of IDs of the database isolated subnets"
  value       = aws_subnet.database[*].id
}

output "database_subnet_cidrs" {
  description = "List of CIDR blocks of the database isolated subnets"
  value       = aws_subnet.database[*].cidr_block
}

output "database_subnet_arns" {
  description = "List of ARNs of the database isolated subnets"
  value       = aws_subnet.database[*].arn
}

output "nat_gateway_ids" {
  description = "List of IDs of the NAT Gateways (empty if NAT is disabled)"
  value       = aws_nat_gateway.main[*].id
}

output "nat_gateway_public_ips" {
  description = "List of public Elastic IPs attached to the NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}

output "nat_eip_allocation_ids" {
  description = "List of Elastic IP allocation IDs used by the NAT Gateways"
  value       = aws_eip.nat[*].id
}


output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "List of IDs of the shared private route table(s) used by frontend + backend subnets (empty if NAT is disabled)"
  value       = aws_route_table.private[*].id
}

output "database_route_table_id" {
  description = "ID of the isolated database route table (no internet route attached)"
  value       = aws_route_table.database.id
}

output "availability_zones" {
  description = "List of Availability Zones used by this VPC"
  value       = var.availability_zones
}
