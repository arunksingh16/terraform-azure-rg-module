# terraform-azure-rg-module
The repository explains about module and versioning mechanism

## How to use RG Module

```
module "rg" {
  source        = "./modules/rg"
  azure_rg_name = var.azure_rg_name
  location      = var.location
}

```
