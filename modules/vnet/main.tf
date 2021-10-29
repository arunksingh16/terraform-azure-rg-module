
#fetch details from existing rg
data azurerm_resource_group "rgdata" {
  name = var.resource_group_name
}



resource "azurerm_network_ddos_protection_plan" "ddos" {
  name                = var.ddos_name
  location            = var.vnet_location != null ? var.vnet_location : data.azurerm_resource_group.rgdata.location
  resource_group_name = data.azurerm_resource_group.rgdata.name
}


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

resource "azurerm_subnet" "subnet" {
  for_each = tomap( var.subnet )
  name                                           = each.key
  resource_group_name                            = data.azurerm_resource_group.rgdata.name
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  address_prefixes                               = each.value
  service_endpoints                              = lookup(var.subnet_service_endpoints, each.key, null)
  enforce_private_link_endpoint_network_policies = lookup(var.subnet_enforce_private_link_endpoint_network_policies, each.key, false)
  enforce_private_link_service_network_policies  = lookup(var.subnet_enforce_private_link_service_network_policies, each.key, false)
  # Designate a subnet to be used by a dedicated service.Learn more.
  
}

locals {
  # The type of brackets around the for expression decide what type of result it produces.
  azurerm_subnets = {
    # A for expression's input (given after the in keyword) can be a list, a set, a tuple, a map, or an object
    for index, subnet in azurerm_subnet.subnet :
    subnet.name => subnet.id
  }
}

resource "azurerm_subnet_network_security_group_association" "vnet" {
  for_each                  = var.nsg_ids
  subnet_id                 = local.azurerm_subnets[each.key]
  network_security_group_id = each.value
}

resource "azurerm_subnet_route_table_association" "vnet" {
  for_each       = var.route_tables_ids
  route_table_id = each.value
  subnet_id      = local.azurerm_subnets[each.key]
}
