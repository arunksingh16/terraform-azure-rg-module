resource "azurerm_resource_group" "azrg" {
  name     = var.azure_rg_name
  location = var.location
}
