# Ec2 instance role
resource "aws_iam_role" "ec2_role" {
  name = "${var.environment}-${var.project_name}-ec2-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}


# ssm
resource "aws_iam_policy_attachment" "ssm_policy" {
  name = "${var.environment}-${var.project_name}-ssm-policy-attachment"
  roles = [aws_iam_role.ec2_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy_attachment" "cloudwatch" {
  name = "${var.environment}-${var.project_name}-cloudwatch-policy-attachment"
  roles = [aws_iam_role.ec2_role.name]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_policy" "secret_manager_policy" {
  name        = "${var.environment}-${var.project_name}-secret-manager-policy"
  description = "Policy for accessing secrets in AWS Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "secret_manager_policy_attachment" {
  name       = "${var.environment}-${var.project_name}-secret-manager-policy-attachment"
  policy_arn = aws_iam_policy.secret_manager_policy.arn
  roles      = [aws_iam_role.ec2_role.name]
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.environment}-${var.project_name}-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}
