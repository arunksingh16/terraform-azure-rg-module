#############################################################################
# TERRAFORM CONFIG
#############################################################################

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
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
##########################

locals {
  ddos_name = "ddos-${var.EnvironmentName}"
}


locals {
  tags = merge(
    var.extra_tags,
    {
      Environment = var.EnvironmentName,
      Project     = "IaaC",
      Department  = "Admin"
    },
  )
}

variable "extra_tags" {
  type    = map(string)
  default = {}
  description = "Extra tags to be included when tagging objects, in addition to the ones provided automatically by this module."
}


variable "EnvironmentName"{
  type    = string
  default = "dev"
}


variable "location" {
  description = "The location of the vnet to create. Defaults to the location of the resource group."
  type        = string
  default     = "eastus"
}


variable "subnet" {
  type    = map(any)
  default = {
    "frontend" = ["10.0.1.0/24"]
    "backend" = ["10.0.2.0/24"]
  }
}

##################


resource "azurerm_resource_group" "test" {
  name     = "rg-vnet"
  location = var.location
}

resource "random_id" "rg_name" {
  byte_length = 8
}

resource "azurerm_network_security_group" "nsg1" {
  name                = "frontend-nsg"
  resource_group_name = azurerm_resource_group.test.name
  location            = var.location
  tags                = local.tags
}

resource "azurerm_network_security_rule" "example" {
  name                        = "http"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.test.name
  network_security_group_name = azurerm_network_security_group.nsg1.name
}

resource "azurerm_route_table" "rt1" {
  name                = "frontend-rt"
  resource_group_name = azurerm_resource_group.test.name
  location            = var.location
  tags                = local.tags
}

module "vnet" {
  source        = "../../modules/vnet"
  resource_group_name = azurerm_resource_group.test.name
  ddos_name           = local.ddos_name
  address_space       = ["10.0.0.0/16"]
  vnet_location       = var.location
  EnvironmentName     = var.EnvironmentName
  depends_on          = [azurerm_resource_group.test]
  tags                = local.tags
  subnet              = var.subnet

  nsg_ids = {
    frontend = azurerm_network_security_group.nsg1.id
  }

  subnet_service_endpoints = {
    frontend = ["Microsoft.Storage", "Microsoft.Sql"],
    backend = ["Microsoft.AzureActiveDirectory"]
  }

  route_tables_ids = {
    frontend = azurerm_route_table.rt1.id
  }

  subnet_enforce_private_link_endpoint_network_policies = {
    backend = true
  }

}


##################

output "vnetid" {
  value = module.vnet.vnet_id
  }


output "vnetname" {
  value = module.vnet.vnet_name
  }

output "subnet" {
  value = module.vnet.subnet_name
}
