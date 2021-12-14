module "cloudfront" {
  source = "terraform-aws-modules/cloudfront/aws"

  aliases = [(length(regexall("prod", var.env)) > 0) ? "${var.name}.${var.domain}" : "${var.name}-${var.env}.${var.domain}"]

  comment             = "${var.name}-${var.env} CloudFront"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_200"
  retain_on_delete    = false
  wait_for_deployment = false

  # When you enable additional metrics for a distribution, CloudFront sends up to 8 metrics to CloudWatch in the US East (N. Virginia) Region.
  # This rate is charged only once per month, per metric (up to 8 metrics per distribution).
  # create_monitoring_subscription = true

  #   create_origin_access_identity = true
  #   origin_access_identities = {
  #     s3_bucket_one = "My awesome CloudFront can access"
  #   }

  #   logging_config = {
  #     bucket = module.log_bucket.s3_bucket_bucket_domain_name
  #     prefix = "cloudfront"
  #   }

  origin = {
    appsync1 = {
#      domain_name = module.alb.lb_dns_name
      domain_name = "jhipster-dev1.jimmy.asia"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }

      custom_header = [
        {
          name  = "X-Forwarded-Scheme"
          value = "https"
        },
        {
          name  = "X-Frame-Options"
          value = "SAMEORIGIN"
        }
      ]

      origin_shield = {
        enabled              = true
        origin_shield_region = "${var.region}"
      }
    }

    appsync2 = {
      #domain_name = module.alb.lb_dns_name
      domain_name = "jhipster-dev1.jimmy.asia"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }

      custom_header = [
        {
          name  = "X-Forwarded-Scheme"
          value = "https"
        },
        {
          name  = "X-Frame-Options"
          value = "SAMEORIGIN"
        }
      ]

      origin_shield = {
        enabled              = true
        origin_shield_region = "${var.region}"
      }
    }

    # s3_one = {
    #   domain_name = module.s3_one.s3_bucket_bucket_regional_domain_name
    #   s3_origin_config = {
    #     origin_access_identity = "s3_bucket_one" # key in `origin_access_identities`
    #     # cloudfront_access_identity_path = "origin-access-identity/cloudfront/E5IGQAA1QO48Z" # external OAI resource
    #   }
    # }
  }

  origin_group = {
    group_one = {
      failover_status_codes    = [403, 404, 500, 502]
      primary_member_origin_id = "appsync1"
      secondary_member_origin_id = "appsync2"
    }
  }

  default_cache_behavior = {
    target_origin_id       = "appsync1"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    query_string           = true

    # This is id for SecurityHeadersPolicy copied from https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-response-headers-policies.html
    response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03"

    # lambda_function_association = {

    #   # Valid keys: viewer-request, origin-request, viewer-response, origin-response
    #   viewer-request = {
    #     lambda_arn   = module.lambda_function.lambda_function_qualified_arn
    #     include_body = true
    #   }

    #   origin-request = {
    #     lambda_arn = module.lambda_function.lambda_function_qualified_arn
    #   }
    # }
  }

  #   ordered_cache_behavior = [
  #     {
  #       path_pattern           = "/static/*"
  #       target_origin_id       = "s3_one"
  #       viewer_protocol_policy = "redirect-to-https"

  #       allowed_methods = ["GET", "HEAD", "OPTIONS"]
  #       cached_methods  = ["GET", "HEAD"]
  #       compress        = true
  #       query_string    = true

  #       function_association = {
  #         # Valid keys: viewer-request, viewer-response
  #         viewer-request = {
  #           function_arn = aws_cloudfront_function.example.arn
  #         }

  #         viewer-response = {
  #           function_arn = aws_cloudfront_function.example.arn
  #         }
  #       }
  #     }
  #   ]

  viewer_certificate = {
    acm_certificate_arn = var.cloudfront_tls_cert_arn
    ssl_support_method  = "sni-only"
  }

  #   geo_restriction = {
  #     restriction_type = "whitelist"
  #     locations        = ["NO", "UA", "US", "GB", "HK"]
  #   }

}
