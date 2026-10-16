terraform {
  required_version = "=1.16.5"

  backend "azurerm" {
    resource_group_name  = "rg-petrip-test"
    storage_account_name = "stppovwantesttfstate"
    container_name       = "tfstaterules"
    key                  = "terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=5.9.0"
    }
    random = {
      version = "=3.9.1"
    }
  }
}

# Define default provider
provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

data "azurerm_client_config" "current" {}