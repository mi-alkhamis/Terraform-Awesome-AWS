provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Project    = "Terraform Awesome"
      Managed_by = "Terraform"
    }
  }
}