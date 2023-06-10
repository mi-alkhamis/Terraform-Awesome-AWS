variable "subnet_cidr_block" {
  default = {
    "az-1" = {
      cidr_block        = "10.10.1.0/24"
      availability_zone = "us-east-1a"
    }
    "az-2" = {
      cidr_block        = "10.10.2.0/24"
      availability_zone = "us-east-1b"
    }
    "az-3" = {
      cidr_block        = "10.10.3.0/24"
      availability_zone = "us-east-1c"
    }
    "az-4" = {
      cidr_block        = "10.10.4.0/24"
      availability_zone = "us-east-1d"
    }
    "az-5" = {
      cidr_block        = "10.10.5.0/24"
      availability_zone = "us-east-1e"
    }
    "az-6" = {
      cidr_block        = "10.10.6.0/24"
      availability_zone = "us-east-1f"
    }
  }
}

variable "network_tags" {
  default = {
    "Name"  = "MainNetwork",
    "Scope" = "NonProd"
  }
}