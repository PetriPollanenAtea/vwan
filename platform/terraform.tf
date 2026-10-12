terraform {
  required_version = "=1.15.8"

  backend "azurerm" {
    resource_group_name  = "rg-petrip-test"
    storage_account_name = "stppovwantesttfstate"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.78.0"
    }
    random = {
      version = "=3.0"
    }
  }
}

# Define default provider
provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

data "azurerm_client_config" "current" {}