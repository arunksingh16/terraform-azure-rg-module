#############################################################################
# TERRAFORM PROVIDERS
#############################################################################
terraform {
  #   backend "azurerm" {
  #         resource_group_name  = "rg-terraform"
  #         storage_account_name = "xxxxx"
  #         container_name       = "xxxxx"
  #         key                  = "adsvc.vnet.terraform.tfstate"
  #     }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"

    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 1.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }

}

provider "azurerm" {
  features {}
  #  subscription_id   = "${var.ARM_SUBSCRIPTION_ID}"
  #  tenant_id         = "${var.ARM_TENANT_ID}"
  #  client_id         = "${var.ARM_CLIENT_ID}"
  #  client_secret     = "${var.ARM_CLIENT_SECRET}"
}

#############################################################################
# TERRAFORM CONFIG
#############################################################################

module "rg" {
  source        = "../../modules/rg"
  azure_rg_name = var.azure_rg_name
  location      = var.location
}
  
#############################################################################
# TERRAFORM VARIABLE
#############################################################################

variable "azure_rg_name" {
  description = "Azure Resource Group Name"
  default     = "rg-dev"
}
variable "location" {
  description = "Default Location"
  default     = "eastus"
}

#############################################################################
# TERRAFORM OUTPUT
#############################################################################
  
output "rg_name" {
  value = module.rg.resource_group_name
}
output "rg_location" {
  value = module.rg.resource_group_loc
}
