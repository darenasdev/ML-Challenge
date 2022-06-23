variable app_name {
  type        = string
  default     = ""
  description = "meli-api"
}

variable vpc_id {
  type        = string
  description = "VPC ID"
}

variable vpc_public_subnets {
  type        = list
  description = "List of public subnets"
}


variable security_groups {
  type        = list
  description = "List of security groups"
}

variable target_port {
  default     = 80
  description = "Target group port"
}
