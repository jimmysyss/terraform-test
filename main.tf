terraform {
  required_version = ">= 0.12"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 2.0"
    }
  }

  backend "remote" {
    organization = "clicktrade"
    workspaces {
      prefix = "jhipster-"
    }
  }
}
