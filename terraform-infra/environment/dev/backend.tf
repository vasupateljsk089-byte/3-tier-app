terraform {
  backend "s3" {
    bucket       = "3-tier-app-terraform-state"
    key          = "dev/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true # native S3 state locking (Terraform >= 1.10), no DynamoDB table needed
  }
}