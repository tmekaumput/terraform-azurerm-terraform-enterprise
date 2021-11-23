# General
# -------
variable "friendly_name_prefix" {
  type        = string
  description = "(Required) Name prefix used for resources"
}

variable "flexible_server" {
  type = bool
  default = true
  description = "Type of Postgres database resource, `azurerm_postgresql_flexible_server` or `azurerm_postgresql_server`"
}

# Provider
# --------
variable "location" {
  type        = string
  description = "(Required) Azure location name e.g. East US"
}

variable "resource_group_name" {
  type        = string
  description = "(Required) Azure resource group name"
}

# Database
# --------
variable "database_user" {
  default     = "tfeuser"
  type        = string
  description = "Postgres username"
}

variable "database_machine_type" {
  type        = string
  description = "Postgres sku short name: tier + family + cores"
}

variable "database_size_mb" {
  type        = number
  description = "Postgres storage size in MB"
}

variable "database_version" {
  type        = string
  description = "Postgres version"
}

variable "database_subnet_id" {
  type        = string
  description = "(Required) Network subnet id for database"
}

variable "database_private_dns_zone_id" {
  type        = string
  description = "The identity of the private DNS zone in which the database will be deployed."
}

# ----
variable "database_backup_retention_days" {
  default     = 7
  type        = number
  description = "Backup retention days for the PostgreSQL server. Supported values are between 7 and 35 days"
}

variable "database_geo_redundant_backup_enabled" {
  default     = true
  type        = bool
  description = <<DESC
  Turn Geo-redundant server backups on/off. This allows you to choose between locally redundant or geo-redundant
  backup storage in the General Purpose and Memory Optimized tiers.
  DESC
}

variable "database_auto_grow_enabled" {
  default     = true
  type        = bool
  description = "Enable/Disable auto-growing of the storage for PostgreSQL server"
}

variable "database_ssl_enforcement_enabled" {
  default     = true
  type        = bool
  description = "Specifies if SSL should be enforced on connections"
}

# Tagging
variable "tags" {
  default     = {}
  type        = map(string)
  description = "Map of tags for resource"
}
