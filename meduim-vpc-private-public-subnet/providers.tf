provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project    = "Terraform Awesome"
      Managed_by = "Terraform"
    }
  }
}