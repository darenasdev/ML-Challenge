variable cs_name {
  type        = string
  default     = ""
  description = "ecs-cluster"
}

variable app_name {
  type        = string
  default     = ""
  description = "meli-api"
}

variable image_url {
  type        = string
  description = "Container image url"
}

variable container_port {
  type        = string
  default     = "80"
  description = "Container port where service is expose"
}

variable host_port {
  type        = string
  default     = "80"
  description = "Host port where container ll'be expose"
}

variable container_cpu {
  type        = string
  default     = "256"
  description = "Container/task cpu"
}

variable container_memory {
  type        = string
  default     = "512"
  description = "description"
}

variable region {
  type        = string
  default     = ""
  description = "AWS region"
}

variable task_memory {
  type        = string
  default     = "512"
  description = "Task memory"
}


variable task_cpu {
  type        = string
  default     = "256"
  description = "Task cpu"
}

variable ecs_task_execution_role_arn {
  type        = string
  description = "ECS task execution role"
}

variable security_groups {
  type        = list
  description = "List of security groups"
}

variable alb_listener {
  description = "Alb listener"
}

variable private_subnets {
  type        = list
  description = "List of private subnets for ecs service"
}

variable alb_tg_arn {
  type        = string
  description = "ALB target group arn"
}



