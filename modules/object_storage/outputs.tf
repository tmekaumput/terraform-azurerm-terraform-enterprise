output "storage_account_id" {
  value       = var.storage_account_name == null ? element(azurerm_storage_account.tfe_storage_account.*.id,0) : null
  description = "The ID of the storage account used by TFE"
}

output "storage_account_name" {
  value       = local.storage_account_name
  description = "The name of the storage account used by TFE"
}

output "storage_account_key" {
  value       = local.storage_account_key
  description = "The Primary Access Key for the storage account used by TFE"
}

output "storage_account_primary_blob_connection_string" {
  value       = local.storage_account_primary_blob_connection_string
  description = "The connection string associated with the primary location for the storage account used by TFE"
}

output "storage_account_container_name" {
  value       = local.storage_account_container_name
  description = "The name of the storage container used by TFE"
}
