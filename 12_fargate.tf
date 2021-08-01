resource "aws_security_group" "fargate" {
  name = "${var.name}-${var.env}-fargate-sg"

  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

########### Service: ${var.name} ###########
resource "aws_cloudwatch_log_group" "app_lg" {
  name              = "${var.name}-${var.env}-logs-group"
  retention_in_days = 1
}

resource "aws_ecs_task_definition" "app_task" {
  family                   = "${var.name}-${var.env}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE", "EC2"]
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = data.aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = data.aws_iam_role.ecsTaskExecutionRole.arn

  container_definitions = <<EOF
[
  {
    "name": "${var.name}",
    "image": "${var.fargate_app_name}",
    "cpu": 0,
    "portMappings": [
      {
        "hostPort": 8080,
        "protocol": "tcp",
        "containerPort": 8080
      }
    ],
    "environment": [
      {
        "name": "SPRING_DATASOURCE_PASSWORD",
        "value": "clicktrade"
      },
      {
        "name": "SPRING_DATASOURCE_URL",
        "value": "jdbc:postgresql://${module.rds.db_instance_endpoint}/clicktrade"
      },
      {
        "name": "SPRING_DATASOURCE_USERNAME",
        "value": "clicktrade"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${var.region}",
        "awslogs-group": "${var.name}-${var.env}-logs-group",
        "awslogs-stream-prefix": "${var.name}"
      }
    }
  }
]
EOF
}

resource "aws_ecs_service" "app_service" {
  name            = "${var.name}-${var.env}-service"
  cluster         = module.ecs.ecs_cluster_id
  task_definition = aws_ecs_task_definition.app_task.arn

  desired_count = 1

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
  launch_type                        = "FARGATE"

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.fargate.id]
  }

  load_balancer {
    target_group_arn = module.alb.target_group_arns[0]
    container_name   = "${var.name}"
    container_port   = 8080
  }
}

data "aws_iam_role" "ecsTaskExecutionRole" {
  name = "ecsTaskExecutionRole"
}
