resource "aws_security_group" "alb" {
  name = "${var.name}-${var.env}-alb-sg"

  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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

module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name = "${var.name}-${var.env}-alb"

  load_balancer_type = "application"

  vpc_id          = module.vpc.vpc_id
  security_groups = [aws_security_group.alb.id]
  subnets         = module.vpc.public_subnets

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    },
  ]

  https_listeners = [
    {
      port     = 443
      protocol = "HTTPS"
      certificate_arn    = var.alb_tls_cert_arn
      target_group_index = 0
    },
  ]

  target_groups = [
    {
      # name_prefix          = "h1"
      name                 = "${var.name}-${var.env}-tg"
      backend_protocol     = "HTTP"
      backend_port         = 8080
      target_type          = "ip"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/actuator/health"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      protocol_version = "HTTP1"
      targets = {
      }
      tags = {
        InstanceTargetGroupTag = "baz"
      }
    },
  ]

  lb_tags = {
    MyLoadBalancer = "foo"
  }

  target_group_tags = {
    MyGlobalTargetGroupTag = "bar"
  }

  https_listener_rules_tags = {
    MyLoadBalancerHTTPSListenerRule = "bar"
  }

  https_listeners_tags = {
    MyLoadBalancerHTTPSListener = "bar"
  }

  http_tcp_listeners_tags = {
    MyLoadBalancerTCPListener = "bar"
  }
}
