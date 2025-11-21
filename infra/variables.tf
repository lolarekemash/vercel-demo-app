variable "location" {
  type    = string
  default = "canadacentral"
}

variable "resource_group_name" {
  type    = string
  default = "lola-app-rg"
}

variable "app_name" {
  type    = string
  default = "vercel-demo-app"
}

variable "environment" {
  type    = string
  default = "prod"
}

# Secret not saved in repo; provided via DevOps variable group or Key Vault manual set
variable "vercel_database_url" {
  type = string
  default = ""
}
 
