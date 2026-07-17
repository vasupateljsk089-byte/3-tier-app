resource "aws_s3_bucket" "terraform_state" {
  bucket = "3-tier-app-terraform-state"
  
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}