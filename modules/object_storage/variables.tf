# General
# -------
variable "friendly_name_prefix" {
  type        = string
  description = "Name prefix used for resources"
}

# Provider
# --------
variable "location" {
  type        = string
  description = "Azure location name e.g. East US"
}

variable "resource_group_name" {
  type        = string
  description = "Azure resource group name"
}

# Storage Account
# ---------------
variable "storage_account_name" {
  type        = string
  description = "Storage account name"
}

variable "storage_account_container_name" {
  type        = string
  description = "Storage account container name"
}

variable "storage_account_tier" {
  default     = "Standard"
  type        = string
  description = "Storage account tier Standard or Premium"
}

variable "storage_account_replication_type" {
  default     = "ZRS"
  type        = string
  description = "Storage account type LRS, GRS, RAGRS, ZRS"
}

variable "storage_account_key" {
  type        = string
  description = "Storage account key"
}

variable "storage_account_primary_blob_connection_string" {
  type        = string
  description = "Storage account primary blob endpoint"
}


variable "allow_blob_public_access" {
  default = false
  type = bool
  description = "'Allow public access to the Storage account"
}

variable "network_rules_default_action" {
  type = string
  description = "Storage account default access rule, which can be 'Allow' or 'Deny'"

  validation {
    condition = contains(["Allow","Deny"], var.network_rules_default_action)  
    error_message = "Storage account default access rule, which can be 'Allow' or 'Deny'."
  }
  
}

variable "default_action_ip_rules" {
  default = []
  type = list(string)
  description = "The IP rules for the Storage account default action"
}

variable "default_action_subnet_ids" {
  default = []
  type = list(string)
  description = "The Subnet Ids for the Storage account default action"
}


# Tagging
# -------
variable "tags" {
  default     = {}
  type        = map(string)
  description = "Map of tags for resource"
}
