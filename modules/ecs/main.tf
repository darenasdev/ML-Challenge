terraform {
    required_version = ">= 1.2.3"
}

resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${var.cs_name}-cluster"

  tags = {
    Name  = "${var.cs_name}-ecs"
  }
}

resource "aws_cloudwatch_log_group" "log-group" {
  name = "${var.app_name}-logs"

  tags = {
    Application = var.app_name
  }
}


resource "aws_ecs_task_definition" "aws-ecs-task" {
  family = "${var.app_name}-task"

  container_definitions = <<DEFINITION
  [
    {
      "name": "${var.app_name}-task",
      "image": "${var.image_url}",
      "entryPoint": [],
      "environment": [],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.log-group.id}",
          "awslogs-region": "${var.region}",
          "awslogs-stream-prefix": "${var.app_name}"
        }
      },
      "portMappings": [
        {
          "containerPort": ${var.container_port},
          "hostPort": ${var.host_port}
        }
      ],
      "cpu": ${var.container_cpu},
      "memory": ${var.container_memory},
      "networkMode": "awsvpc"
    }
  ]
  DEFINITION

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "${var.task_memory}"
  cpu                      = "${var.task_cpu}"
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_execution_role_arn

  tags = {
    Name = "${var.app_name}-task"
  }
}

data "aws_ecs_task_definition" "main" {
  task_definition = aws_ecs_task_definition.aws-ecs-task.family
}

resource "aws_ecs_service" "aws-ecs-service" {
  name                 = "${var.app_name}-service"
  cluster              = aws_ecs_cluster.ecs-cluster.id
  task_definition      = "${aws_ecs_task_definition.aws-ecs-task.family}:${max(aws_ecs_task_definition.aws-ecs-task.revision, data.aws_ecs_task_definition.main.revision)}"
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true

  network_configuration {
    subnets          = var.private_subnets
    assign_public_ip = false
    security_groups = var.security_groups
  }

  load_balancer {
    target_group_arn = var.alb_tg_arn
    container_name   = "${var.app_name}-task"
    container_port   = var.container_port
  }

  depends_on = [var.alb_listener]
}
