resource "aws_route53_record" "main" {
  zone_id = var.zone_id
  name    = (length(regexall("prod", var.env)) > 0) ? "${var.name}.${var.domain}" : "${var.name}-${var.env}.${var.domain}"
  type    = "A"
  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
}
