provider "aws" {
  region = "eu-west-3"
}

# ------------------------------------------------------------------------------
# Cloudwatch
# ------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "minecraft_server" {
  name              = var.application_name
  retention_in_days = 3
}

# ------------------------------------------------------------------------------
# VPC
# ------------------------------------------------------------------------------
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "minecraft_vpc"
  cidr = "10.0.0.0/16"
  azs = ["${var.region}a", "${var.region}b", "${var.region}c"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

# ------------------------------------------------------------------------------
# Security Groups
# ------------------------------------------------------------------------------
resource "aws_security_group" "efs" {
  name        = "${var.application_name}-efs-sg"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "ingress_efs" {
  security_group_id        = aws_security_group.efs.id
  description              = "Allow connections to EFS"
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs_service.id
}

resource "aws_security_group" "ecs_service" {
  depends_on = [aws_iam_role_policy.log_agent]
  name        = "${var.application_name}-sg"
  description = "Fargate service security group"
  vpc_id      =  module.vpc.vpc_id
}

resource "aws_security_group_rule" "ingress_minecraft" {
  security_group_id = aws_security_group.ecs_service.id
  description       = "Allow connections to the Minecraft server"
  type              = "ingress"
  from_port         = 25565
  to_port           = 25565
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "egress_all" {
  security_group_id = aws_security_group.ecs_service.id
  description      = "Allow outbound traffic to AWS services"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# ------------------------------------------------------------------------------
# ECS Cluster
# ------------------------------------------------------------------------------
resource "aws_ecs_cluster" "minecraft_server" {
  name = var.application_name
}

resource "aws_ecs_task_definition" "minecraft_server" {
  cpu                      = "1024"
  memory                   = "2048"
  family                   = var.application_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.execution.arn
  container_definitions = jsonencode([
    {
      name          = var.application_name
      image         = var.container_image
      essential     = true
      tty           = true
      stdin_open    = true
      restart       = "unless-stopped"
      portMappings  = [
        {
          containerPort = 25565
          hostPort      = 25565
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
            awslogs-create-group  = "true",
            awslogs-group         = aws_cloudwatch_log_group.minecraft_server.name,
            awslogs-region        = var.region,
            awslogs-stream-prefix = "ecs"
        }
      }
      mountPoints   = [
        {
          containerPath = "/srv/minecraft/world"
          sourceVolume  = "minecraft-data"
        }
      ]
    }
  ])
  volume {
    name = "minecraft-data"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.minecraft_server.id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.minecraft_server.id
      }
    }
  }
}

resource "aws_ecs_service" "minecraft_server" {
  name            = var.application_name
  cluster         = aws_ecs_cluster.minecraft_server.id
  task_definition = aws_ecs_task_definition.minecraft_server.arn
  desired_count   = 1
  network_configuration {
    subnets          = module.vpc.public_subnets
    security_groups  = [aws_security_group.ecs_service.id]
    assign_public_ip = true
  }
  launch_type = "FARGATE"
}
