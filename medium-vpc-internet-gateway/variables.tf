variable "region" {
  default = "us-east-1"
}

variable "public_subnet_cidr" {
  default = {
    "az-1" = {
      cidr_block          = "10.10.1.0/24"
      availability_zone   = "us-east-1a"
      public_ip_on_launch = true
      scope               = "Public"
    }
    "az-2" = {
      cidr_block          = "10.10.2.0/24"
      availability_zone   = "us-east-1b"
      public_ip_on_launch = true
      scope               = "Public"
    }
    "az-3" = {
      cidr_block          = "10.10.3.0/24"
      availability_zone   = "us-east-1c"
      public_ip_on_launch = true
      scope               = "Public"
    }
  }
}

variable "network_tags" {
  default = {
    "Environment" = "Main",
    "Scope"       = "NonProd"
  }
}