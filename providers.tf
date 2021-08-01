provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Group = var.name
      Env   = var.env
    }
  }
}

provider "cloudflare" {
}

data "aws_availability_zones" "available" {
  state = "available"
}
