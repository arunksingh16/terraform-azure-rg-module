# terraform-azure-rg-module
The repository explains about module and versioning mechanism.


## Module Basics
- Module naming standard need to be followed
- Use validation rules in respect to variables if required
- Structure your module as per your requirement
- Follow terraform suggestion `A good module should raise the level of abstraction by describing a new concept in your architecture that is constructed from resource types offered by providers. We do not recommend writing modules that are just thin wrappers around single other resource types.`
- Test your module (terratest / tfsec by aquasecurity)

## How to use any Module in GitHub

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
  source = "git::https://github.com/arunksingh16/terraform-azure-rg-module.git//modules/rg?ref=main"
  azure_rg_name = "rg-uat"
  location      = "eastus"
}
``` 
