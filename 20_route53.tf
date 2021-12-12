module "zones" {
  source = "terraform-aws-modules/route53/aws//modules/zones"

  zones = {
    "jhipster.jimmysyss.com" = {
      comment = "jhipster.jimmysyss.com"
    }

    # "app.terraform-aws-modules-example.com" = {
    #   comment = "app.terraform-aws-modules-example.com"
    # }

    # "private-vpc.terraform-aws-modules-example.com" = {
    #   # in case than private and public zones with the same domain name
    #   domain_name = "terraform-aws-modules-example.com"
    #   comment     = "private-vpc.terraform-aws-modules-example.com"
    #   vpc = [
    #     {
    #       vpc_id = module.vpc.vpc_id
    #     },
    #     {
    #       vpc_id = module.vpc2.vpc_id
    #     },
    #   ]
    # }
  }
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"

  zone_name = keys(module.zones.route53_zone_zone_id)[0]

  records = [
    {
      name    = "${var.env}"
      type    = "A"
      alias   = {
        name    = module.alb.lb_dns_name
        zone_id = module.zones.route53_zone_zone_id
      }
    },
  ]

  depends_on = [module.zones]
}