resource "aws_route53_record" "alb" {
  zone_id = var.zone_id
  name    = (length(regexall("prod", var.env)) > 0) ? "${var.name}-alb" : "${var.name}-${var.env}-alb"
  type    = "A"
  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "main" {
  zone_id = var.zone_id
  name    = (length(regexall("prod", var.env)) > 0) ? "${var.name}" : "${var.name}-${var.env}"
  type    = "A"
  alias {
    name                   = module.cloudfront.cloudfront_distribution_domain_name
    zone_id                = module.cloudfront.cloudfront_distribution_hosted_zone_id
    evaluate_target_health = true
  }
}
