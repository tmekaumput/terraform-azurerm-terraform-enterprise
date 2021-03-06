# Required Providers
# ------------------
# https://registry.terraform.io/providers/hashicorp/azurerm/latest
terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.79.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0.0"
    }
  }
}
