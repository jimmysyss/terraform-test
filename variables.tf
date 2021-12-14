variable "region" {
  description = "AWS region to launch servers."
  default     = ""
}

variable "vpc_azs" {
  description = "A list of availability zones in the region"
  default     = []
}

variable "name" {
  description = "The name of the deployment"
  default     = ""
}

variable "env" {
  description = "The name of the Env, dev | stage | test | prod"
  default     = ""
}

variable "domain" {
  description = "Target domain name *.example.com"
  default     = ""
}

variable "zone_id" {
  description = "Route 53 Zone ID"
  default     = "Z078377437DBQZBAF6HN9"
}

variable "fargate_app_name" {
  description = "Target Docker image to run"
  default     = "jimmysyss/clicktrade:latest"
}


####################################################
# THE FOLLOWING VARIABLES DON'T NEED TO BE DEFINED #
####################################################
variable "vpc_cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overriden"
  default     = "10.0.0.0/16"
}

variable "vpc_public_subnets" {
  description = "A list of public subnets inside the VPC"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
}

variable "vpc_private_subnets" {
  description = "A list of private subnets inside the VPC"
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24", "10.0.14.0/24", "10.0.15.0/24"]
}

variable "vpc_database_subnets" {
  description = "A list of database subnets"
  default     = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24", "10.0.24.0/24", "10.0.25.0/24"]
}

variable "vpc_enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  default     = true
}

variable "vpc_single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  default     = false
}

variable "vpc_one_nat_gateway_per_az" {
  description = "Should be true if you want only one NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs`."
  default     = true
}

variable "alb_tls_cert_arn" {
  description = "AWS Certificate ARN for TLS Cert on ALB"
  default     = "arn:aws:acm:ap-southeast-1:013813894368:certificate/b442a344-f7b8-4641-9a71-3b58824a535e"
}

variable "cloudfront_tls_cert_arn" {
  description = "AWS Certificate ARN for TLS Cert on Cloudfront"
  default     = "arn:aws:acm:us-east-1:013813894368:certificate/896a0674-9178-4c48-af53-f3fd8fb9c61f"
}

variable "db_allocated_storage" {
  description = "The allocated storage in GB"
  default     = 5
}

variable "db_username" {
  description = "Username for the master DB user"
  default     = "postgres"
}

variable "db_password" {
  description = "Password for the master DB user"
  default     = "postgres"
}

variable "db_port" {
  description = "The port on which the DB accepts connections"
  default     = 5432
}

variable "db_maintenance_window" {
  description = "The window to perform maintenance in"
  default     = "Sun:00:00-Sun:03:00"
}

variable "db_backup_window" {
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled"
  default     = "03:00-06:00"
}

variable "db_backup_retention_period" {
  description = "The days to retain backups for"
  default     = 2
}