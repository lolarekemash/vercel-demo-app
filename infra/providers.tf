 terraform {
  required_version = ">= 1.5.0"

  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"          
    storage_account_name = "lolacanadacentral12345"      
    container_name       = "tfstate"
    key                  = "vercel-to-azure.tfstate"
  }
}

provider "azurerm" {
  features {}
}

