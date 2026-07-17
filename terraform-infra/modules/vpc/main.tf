# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-vpc"
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-igw"
    }
  )
}

# Public Subnets (Web Tier)
resource "aws_subnet" "public" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.main.id # which vpc to create the subnet in
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-public-subnet-${count.index + 1}"
      Tier = "public"
    }
  )
}

# Frontend Private Subnets (App Tier - Frontend)
resource "aws_subnet" "frontend" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id 
  cidr_block        = var.frontend_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-frontend-subnet-${count.index + 1}"
      Tier = "frontend"
    }
  )
}

# Backend Private Subnets (App Tier - Backend)
resource "aws_subnet" "backend" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.backend_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-backend-subnet-${count.index + 1}"
      Tier = "backend"
    }
  )
}

# Database Isolated Subnets (Data Tier)
resource "aws_subnet" "database" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.database_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-database-subnet-${count.index + 1}"
      Tier = "database"
    }
  )
}

# Elastic IPs for NAT Gateways (if single NAT gateway is used, only one EIP will be created)
resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.availability_zones)) : 0
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-nat-eip-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# NAT Gateways
resource "aws_nat_gateway" "main" {
  count         = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.availability_zones)) : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-nat-gw-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-public-rt"
      Tier = "public"
    }
  )
}

# Route for Public Subnets to Internet Gateway
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Associate Public Subnets with Public Route Table
# all public subnet will be associated with the public route table
resource "aws_route_table_association" "public" {
  count          = length(var.availability_zones) # both public subnet point to the same route table
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
# Shared Private Route Table for Frontend + Backend (App Tier)
resource "aws_route_table" "private" {
  count  = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.availability_zones)) : 0
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-private-rt-${count.index + 1}"
      Tier = "private" # shared by frontend + backend
    }
  )
}

# Route for Private Subnets (frontend + backend) to NAT Gateway
resource "aws_route" "private_nat" {
  count                  = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.availability_zones)) : 0
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.single_nat_gateway ? aws_nat_gateway.main[0].id : aws_nat_gateway.main[count.index].id
}

# Associate Frontend Subnets with Private Route Table
resource "aws_route_table_association" "frontend" {
  count     = length(var.availability_zones)
  subnet_id = aws_subnet.frontend[count.index].id
  route_table_id = var.enable_nat_gateway ? (
    var.single_nat_gateway ? aws_route_table.private[0].id : aws_route_table.private[count.index].id
  ) : null
}

# Associate Backend Subnets with the SAME Private Route Table
resource "aws_route_table_association" "backend" {
  count     = length(var.availability_zones)
  subnet_id = aws_subnet.backend[count.index].id
  route_table_id = var.enable_nat_gateway ? (
    var.single_nat_gateway ? aws_route_table.private[0].id : aws_route_table.private[count.index].id
  ) : null
}

# ── Database keeps its OWN isolated route table — never merge this in ──
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-database-rt"
      Tier = "database"
    }
  )
  # No aws_route resource attached — fully isolated, no internet path
}

resource "aws_route_table_association" "database" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}