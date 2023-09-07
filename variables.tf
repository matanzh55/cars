variable "azure_subscription_id" {
  description = "Azure Subscription ID"
}

variable "resource_group_name" {
  description = "Azure Resource Group Name"
  default     = "rg-cars"
}

variable "location" {
  description = "Azure Region"
  default     = "West Europe"
}

variable "admin_username" {
  description = "VM Admin Username"
  default     = "matanzh"
}

