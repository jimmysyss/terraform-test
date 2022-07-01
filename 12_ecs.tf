module "key_pair" {
  source     = "terraform-aws-modules/key-pair/aws"
  key_name   = "${var.name}-${var.env}-ssh"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/te8jtSYXkNDwNWAR2GcNpXoDQPQh3/7SP6571rfLbWLp4aeZE2Sfx4KD6O8HxCsukfcVvRqUCv0yp6CzgN22apNP8lDdXP8b9aPF8fusMMHSev91vu0ms4wdP8Bv+UlknjutpPRo2/cwUYyQTJ2M1wTjBzUFQQf2eW0ihwOeHvb03rEKD3UvgZPXBVfxK43pVzstmMrkF14DP45zFra+lpol2uakRJDJ//7zUcPUW2J5SuOPWbUngIoQ5SzhYaxHZNAUQ55vk0ZpgtWwFKGHFltwIlKNp34fXwSI9vJXViZ8Ee6qdpt6dg3TFMmMKWiA9T4SOMj70rQ4PEZ6r/hh pi@raspberrypi"
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

}

module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = "${var.name}-${var.env}-ecs"

  # container_insights = true

    cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        # You can set a simple string and ECS will create the CloudWatch log group for you
        # or you can create the resource yourself as shown here to better manage retetion, tagging, etc.
        # Embedding it into the module is not trivial and therefore it is externalized
        cloud_watch_log_group_name = aws_cloudwatch_log_group.this.name
      }
    }
  }

  # Capacity provider
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
        base   = 20
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }
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
  version = "~> 4.0"

  name = "${var.name}-${var.env}-asg"

  # Launch configuration
  lc_name   = "${var.name}-${var.env}-asg"
  use_lc    = true
  create_lc = true

  image_id                  = data.aws_ami.amazon_linux_ecs.id
  instance_type             = "t3.micro"
  security_groups           = [aws_security_group.ecs.id]
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

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/ecs/${var.name}-${var.env}"
  retention_in_days = 7
}