# terraform-azure-rg-module
The repository explains about module and versioning mechanism

## How to use RG Module

- Locally
```
module "rg" {
  source        = "./modules/rg"
  azure_rg_name = var.azure_rg_name
  location      = var.location
}
```

- Using GitHub
```
module "rg" {
  source = "git::https://github.com/arunksingh16/terraform-azure-rg-module.git//modules/rg"
  azure_rg_name = "rg-uat"
  location      = "eastus"
}
``` 
