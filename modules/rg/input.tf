variable "azure_rg_name" {
  description = "Azure Resource Group Name"
}

variable "location" {
  description = "Default Location"
}

variable "tf-env" {
  type    = string
  default =  "poc"
}
