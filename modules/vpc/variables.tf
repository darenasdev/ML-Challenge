variable vpc_name {
  type        = string
  default     = "vpc_aws"
  description = "VPC name"
}

variable cidr_block {
  description = "cidr block value"
}

variable private_subnet_cidr {
  type          = list
  default       = []
  description   = "List of private subnets"
}

variable public_subnet_cidr {
  type          = list
  default       = []
  description   = "List of public subnets"
}

variable availability_zones {
  type        = list
  default     = []
  description = "List of az's"
}
