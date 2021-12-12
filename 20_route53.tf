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
      name    = "ALB"
      type    = "A"
      alias   = {
        name    = "d-10qxlbvagl.execute-api.eu-west-1.amazonaws.com"
        zone_id = "ZLY8HYME6SFAD"
      }
    },
  ]

  depends_on = [module.zones]
}