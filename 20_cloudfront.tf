#
# Cloudfront is not a proper solution, we need to seperate API and static content
#
# Easier to use Cloudflare
#

# module "cloudfront" {
#   source = "terraform-aws-modules/cloudfront/aws"

#   aliases = [(length(regexall("prod", var.env)) > 0) ? "${var.name}.${var.domain}" : "${var.name}-${var.env}.${var.domain}"]

#   comment             = "${var.name}-${var.env} CloudFront"
#   enabled             = true
#   is_ipv6_enabled     = true
#   price_class         = "PriceClass_200"
#   retain_on_delete    = false
#   wait_for_deployment = false

#   origin = {
#     appsync1 = {
#       domain_name = "${var.name}-${var.env}-alb.${var.domain}"
#       custom_origin_config = {
#         http_port              = 80
#         https_port             = 443
#         origin_protocol_policy = "https-only"
#         origin_ssl_protocols   = ["TLSv1.2"]
#       }

#       custom_header = [
#         {
#           name  = "X-Forwarded-Scheme"
#           value = "https"
#         },
#         {
#           name  = "X-Frame-Options"
#           value = "SAMEORIGIN"
#         }
#       ]

#       origin_shield = {
#         enabled              = false
#         origin_shield_region = "${var.region}"
#       }
#     }

#     appsync2 = {
#       domain_name = "${var.name}-${var.env}-alb.${var.domain}"
#       custom_origin_config = {
#         http_port              = 80
#         https_port             = 443
#         origin_protocol_policy = "https-only"
#         origin_ssl_protocols   = ["TLSv1.2"]
#       }

#       custom_header = [
#         {
#           name  = "X-Forwarded-Scheme"
#           value = "https"
#         },
#         {
#           name  = "X-Frame-Options"
#           value = "SAMEORIGIN"
#         }
#       ]

#       origin_shield = {
#         enabled              = false
#         origin_shield_region = "${var.region}"
#       }
#     }
#   }

#   origin_group = {
#     group_one = {
#       failover_status_codes    = [500, 502, 503, 504]
#       primary_member_origin_id = "appsync1"
#       secondary_member_origin_id = "appsync2"
#     }
#   }

#   ordered_cache_behavior = [{
#     path_pattern           = "/api/*"
#     target_origin_id       = "appsync1"
#     viewer_protocol_policy = "redirect-to-https"
#     allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
#     cached_methods         = ["GET", "HEAD"]
#     compress               = true
#     query_string           = true
#     forwarded_values       = [{
#       headers      = ["Authorization"]
#     }]
#   }]

#   default_cache_behavior = {
#     target_origin_id       = "group_one"
#     viewer_protocol_policy = "redirect-to-https"
#     allowed_methods        = ["GET", "HEAD", "OPTIONS"]
#     cached_methods         = ["GET", "HEAD"]
#     compress               = true
#     query_string           = true

#     # This is id for SecurityHeadersPolicy copied from https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-response-headers-policies.html
#     response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03"
#   }

#   viewer_certificate = {
#     acm_certificate_arn = var.cloudfront_tls_cert_arn
#     ssl_support_method  = "sni-only"
#     minimum_protocol_version = "TLSv1.2_2018"
#   }

# }
