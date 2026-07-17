# External Load balancer's Security Group 
resource "aws_security_group" "external_alb" {
  name        = "${var.environment}-${var.project_name}-alb-sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      =  var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  } 

  tags = merge(
    var.tags,
    {Name = "${var.environment}-${var.project_name}-alb-sg"}
  )
}

# security group for frontend EC2 instances
resource "aws_security_group" "frontend" {
  name        = "${var.environment}-${var.project_name}-frontend-sg"
  description = "Allow HTTP inbound traffic from external ALB and all outbound traffic"
  vpc_id      =  var.vpc_id

  ingress {
    description = "HTTP from external ALB"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    security_groups = [aws_security_group.external_alb.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(
    var.tags,
    {Name = "${var.environment}-${var.project_name}-frontend-sg"}
  )
}

# Security group for backend EC2 instances
resource "aws_security_group" "backend" {
  name        = "${var.environment}-${var.project_name}-backend-sg"
  description = "Allow HTTP inbound traffic from internal ALB and all outbound traffic"
  vpc_id      =  var.vpc_id

  ingress {
    description = "HTTP from internal ALB"
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
    security_groups = [aws_security_group.external_alb.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {Name = "${var.environment}-${var.project_name}-backend-sg"}
  )
}

# Security group for database EC2 instances
resource "aws_security_group" "database" {
  name        = "${var.environment}-${var.project_name}-database-sg"
  description = "Allow MySQL inbound traffic from backend EC2 instances and all outbound traffic"
  vpc_id      =  var.vpc_id

  ingress {
    description = "PostgreSQL from backend EC2 instances"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.backend.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {Name = "${var.environment}-${var.project_name}-database-sg"}
  )
}
