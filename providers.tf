terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "devops-state-rg"
    storage_account_name = "devopsstateaccount"
    container_name       = "terraform-state"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  resource_provider_registrations = "none"
  features {}
}