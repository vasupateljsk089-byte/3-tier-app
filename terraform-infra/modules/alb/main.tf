# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.environment}-${var.project_name}-${var.name_prefix}alb"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.subnet_ids

  enable_deletion_protection       = var.enable_deletion_protection
  enable_http2                     = true
  enable_cross_zone_load_balancing = true
  idle_timeout                     = 60

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-${var.name_prefix}alb"
    }
  )
}

# Frontend Target Group
resource "aws_lb_target_group" "main" {
  name     = "${var.environment}-${var.project_name}-${var.name_prefix}tg"
  port     = var.target_group_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-299"
  }

  deregistration_delay = 30

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = true
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-${var.name_prefix}tg"
    }
  )
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = var.enable_https_redirect ? "redirect" : "forward"

    dynamic "redirect" {
      for_each = var.enable_https_redirect ? [1] : []

      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    target_group_arn = var.enable_https_redirect ? null : aws_lb_target_group.main.arn
  }
}

resource "aws_lb_listener" "https" {
  count = var.certificate_arn != "" ? 1 : 0

  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn = var.certificate_arn

  # Default = Frontend
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# Route only /api/* to Backend
resource "aws_lb_listener_rule" "api" {

  listener_arn = aws_lb_listener.https[0].arn

  priority = 10

  action {
    type             = "forward"
    target_group_arn = var.backend_target_group_arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}