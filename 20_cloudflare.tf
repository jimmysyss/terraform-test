data "cloudflare_zones" "domain" {
  filter {
    name = var.domain
  }
}

# Primary Site
resource "cloudflare_record" "www" {
  zone_id = data.cloudflare_zones.domain.zones[0].id
  name    = (length(regexall("prod", var.env)) > 0) ? "${var.name}.${var.domain}" : "${var.name}-${var.env}.${var.domain}"
  value   = module.alb.lb_dns_name
  type    = "CNAME"
  ttl     = 1
  proxied = false
}
