terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

locals {
    project_name        = "meli"
    region              = "us-east-1"
    vpc_name            = "meli-vpc"
    full_cidr_block     = "180.0.0.0/16"
    private_subnet_cidr = ["180.0.1.0/24", "180.0.2.0/24"]
    public_subnet_cidr  = ["180.0.3.0/24", "180.0.4.0/24"]
    availability_zones  = ["us-east-1a", "us-east-1b"]
    app_name            = "meli-api"
}

module vpc {
  source                = "./modules/vpc"
  vpc_name              = local.vpc_name
  cidr_block            = local.full_cidr_block
  private_subnet_cidr   = local.private_subnet_cidr
  public_subnet_cidr    = local.public_subnet_cidr
  availability_zones    = local.availability_zones
}

# Create SG
resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "http from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "SG-${local.project_name}-allow_http"
  }
}


# Create ECR

resource "aws_ecr_repository" "aws-ecr" {
  name = "${local.project_name}-ecr"
  tags = {
    Name        = "${local.project_name}-ecr"
  }
}

# Create Policies for ECS

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "${local.project_name}-execution-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags = {
    Name        = "${local.project_name}-iam-role"
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

module alb {
  source = "./modules/alb"
  app_name            = local.app_name
  vpc_id              = module.vpc.vpc_id
  vpc_public_subnets  = module.vpc.vpc_public_subnets
  security_groups     = [aws_security_group.allow_http.id]
}


module ecs {
  source                      = "./modules/ecs"
  region                      = local.region
  cs_name                     = local.project_name
  app_name                    = local.app_name
  alb_listener                = module.alb.aws_lb_listener
  alb_tg_arn                  = module.alb.alb_target_group_arn
  image_url                   = "${aws_ecr_repository.aws-ecr.repository_url}:latest"
  security_groups             = [aws_security_group.allow_http.id]
  private_subnets             = module.vpc.vpc_private_subnets
  ecs_task_execution_role_arn = aws_iam_role.ecsTaskExecutionRole.arn
}
