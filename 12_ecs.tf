module "key_pair" {
  source     = "terraform-aws-modules/key-pair/aws"
  key_name   = "${var.name}-${var.env}-ssh"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAnedrLwgS91xytxmbsF79WN5tXNQ8aGN6akN3n7kwEHvvhW6cI6EhbQDBkdDI0UmN/HaJ8BaVOsooFEFx1fgifo+MuFh/NriKKUOXSzW7HVGfztsAfOJQJGS3xX2I1xZDYyM24uax1whycqJApOU3TE9YJXFWvoA9Kwz9J8Pfkii9s9UkmuqSwI9hLagpmGF1h3ytCjlZUuLGu/7zyh8dJjTyiJ3AFxz9U0MQUoH2xbwr4LGb7lqsRWibtPeyaFgqP7+NtyiMNi7PwQdDPNx1Ztr/eu5xmiM61/8KhnZTVt/x0Cvrdifdbjy9gxvuQdqVX8VZZsZ5TuOMU1hoiFvC1w== rsa-key-20210721"
  # tags = {
  #   Group = var.name
  #   Env   = var.env
  # }
}

resource "aws_security_group" "ecs" {
  name = "${var.name}-${var.env}-ecs-sg"

  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

  # tags = {
  #   Group = var.name
  #   Env   = var.env
  # }
}

resource "aws_ecs_capacity_provider" "prov1" {
  name = "${var.name}-${var.env}-prov1"

  auto_scaling_group_provider {
    auto_scaling_group_arn = module.asg.autoscaling_group_arn
  }
}

module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  name = "${var.name}-${var.env}-ecs"

  container_insights = true

  capacity_providers = ["FARGATE", "FARGATE_SPOT", aws_ecs_capacity_provider.prov1.name]

  default_capacity_provider_strategy = [
    {
      capacity_provider = aws_ecs_capacity_provider.prov1.name #"FARGATE_SPOT"
      weight            = "1"
    }
  ]

  # tags = {
  #   Group = var.name
  #   Env   = var.env
  # }
}

module "ec2_profile" {
  source = "terraform-aws-modules/ecs/aws//modules/ecs-instance-profile"

  name = "${var.name}-${var.env}-instance-profile"

  # tags = {
  #   Group = var.name
  #   Env   = var.env
  # }
}

#For now we only use the AWS ECS optimized ami <https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html>
data "aws_ami" "amazon_linux_ecs" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    #values = ["amzn-ami-*-amazon-ecs-optimized"]
    values = ["amzn2-ami-ecs-hvm-2.0.*-x86_64-ebs"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

module "asg" {
  source = "terraform-aws-modules/autoscaling/aws"
  #version = "~> 4.0"

  name = "${var.name}-${var.env}-asg"

  # Launch configuration
  lc_name   = "${var.name}-${var.env}-asg"
  #use_lc    = true
  #create_lc = true

  image_id                  = data.aws_ami.amazon_linux_ecs.id
  instance_type             = "t3.micro"
  security_groups           = [aws_security_group.ecs.id]
  iam_instance_profile_name = module.ec2_profile.iam_instance_profile_id
  user_data                 = data.template_file.user_data.rendered

  # Auto scaling group
  vpc_zone_identifier       = module.vpc.public_subnets
  health_check_type         = "EC2"
  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 1 # we don't need them for the example
  wait_for_capacity_timeout = 0
  key_name                  = module.key_pair.key_pair_key_name
}

data "template_file" "user_data" {
  template = file("./user-data.sh")

  vars = {
    cluster_name = "${var.name}-${var.env}-ecs"
  }
}

########### HELLO WORLD ###########
# resource "aws_cloudwatch_log_group" "nginx_tf" {
#   name              = "nginx-logs-group"
#   retention_in_days = 1
# }

# resource "aws_ecs_task_definition" "nginx_tf" {
#   family       = "nginx_tf"
#   network_mode = "host"

#   container_definitions = <<EOF
# [
#   {
#     "name": "nginx",
#     "image": "nginx",
#     "cpu": 0,
#     "memory": 128,
#     "logConfiguration": {
#       "logDriver": "awslogs",
#       "options": {
#         "awslogs-region": "${var.region}",
#         "awslogs-group": "nginx-logs-group",
#         "awslogs-stream-prefix": "ecs"
#       }
#     }
#   }
# ]
# EOF
# }

# resource "aws_ecs_service" "primary" {
#   name            = "primary"
#   cluster         = module.ecs.ecs_cluster_id
#   task_definition = aws_ecs_task_definition.nginx_tf.arn

#   desired_count = 1

#   deployment_maximum_percent         = 100
#   deployment_minimum_healthy_percent = 0
# }
