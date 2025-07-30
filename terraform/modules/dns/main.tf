terraform {
  backend "s3" {
    key = "dns/terraform.tfstate"
  }
  required_providers {
    technitium = {
      source  = "kevynb/technitium"
      version = "0.2.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.84.0"
    }
  }
}

provider "technitium" {
  url   = var.url
  token = var.api_token
}
