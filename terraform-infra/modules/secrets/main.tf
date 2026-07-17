resource "aws_secretsmanager_secret" "db_credentials" {
  name = "${var.project_name}-${var.environment}-db-credentials"
  description = "Database credentials for ${var.project_name} in ${var.environment} environment"

  recovery_window_in_days = var.recovery_window_in_days
  
  lifecycle {
    prevent_destroy = false
  }

    tags = merge(var.tags, {
      "Name" = "${var.project_name}-${var.environment}-db-credentials"
    })

}

# Secret version containing the database credentials
resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id

  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    engine   = "postgres"
    host     = var.db_host
    port     = var.db_port
    dbname   = var.db_name
  })
}

