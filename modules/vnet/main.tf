
# fetch details from existing rg
data azurerm_resource_group "rgdata" {
  name = var.resource_group_name
}
# adding ddos protection plan
resource "azurerm_network_ddos_protection_plan" "ddos" {
  name                = var.ddos_name
  location            = var.vnet_location != null ? var.vnet_location : data.azurerm_resource_group.rgdata.location
  resource_group_name = data.azurerm_resource_group.rgdata.name
}

# vnet
resource azurerm_virtual_network "vnet" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.rgdata.name
  location            = var.vnet_location != null ? var.vnet_location : data.azurerm_resource_group.rgdata.location
  address_space       = var.address_space
  dns_servers         = var.dns_servers
  tags                = var.tags

  ddos_protection_plan {
    id     = azurerm_network_ddos_protection_plan.ddos.id
    enable = true
  }
}

# subnet
resource "azurerm_subnet" "subnet" {
  for_each = tomap( var.subnet )
  name                                           = each.key
  resource_group_name                            = data.azurerm_resource_group.rgdata.name
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  address_prefixes                               = each.value

}
