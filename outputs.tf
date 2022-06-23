output vpc_id {
    description = "Vpc id"
    value       = module.vpc.vpc_id
}

output "vpc_main_rt" {
  value       = module.vpc.vpc_main_rt
  description = "Vpc main route table"
}


output vpc_private_subnets {
  value       = module.vpc.vpc_private_subnets
  description = "List of private networks genereted"
}


output vpc_public_subnets {
  value       = module.vpc.vpc_public_subnets
  description = "List of private networks genereted"
}

output registry_url {
  value       = aws_ecr_repository.aws-ecr.repository_url
  description = "Ecr registry url"
}
