resource "azurerm_private_dns_zone" "storage_account" {
  count = var.private_link_enforced ? 1 : 0
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone" "postgres" {
  count = var.private_link_enforced && !var.database_flexible_server ? 1 : 0
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_account" {
  count = var.private_link_enforced ? 1 : 0
  name                  = "${var.friendly_name_prefix}dnsvnlinksa"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = element(azurerm_private_dns_zone.storage_account.*.name,0)
  virtual_network_id    = var.virtual_network_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  count = var.private_link_enforced && !var.database_flexible_server ? 1 : 0
  name                  = "${var.friendly_name_prefix}dnsvnlinkpg"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = element(azurerm_private_dns_zone.postgres.*.name,0)
  virtual_network_id    = var.virtual_network_id
}

resource "azurerm_private_endpoint" "storage_account" {
  count = var.private_link_enforced ? 1 : 0
  name                = "${var.friendly_name_prefix}-ep-sa"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.dedicated_subnets ? var.storage_subnet_id : var.application_subnet_id
  
  private_dns_zone_group {
    name                 = "${var.friendly_name_prefix}-dns-zone-sa"
    private_dns_zone_ids = [element(azurerm_private_dns_zone.storage_account.*.id,0)]
  }

  private_service_connection {
    name                           = "${var.friendly_name_prefix}-pvsc-sa"
    private_connection_resource_id = var.storage_account_id
    is_manual_connection = false
    subresource_names    = ["blob"]
  }
}

resource "azurerm_private_endpoint" "postgres" {
  count = var.private_link_enforced && !var.database_flexible_server ? 1 : 0
  name                = "${var.friendly_name_prefix}-ep-pg"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.dedicated_subnets ? var.database_subnet_id : var.application_subnet_id
  
  private_dns_zone_group {
    name                 = "${var.friendly_name_prefix}-dns-zone-pg"
    private_dns_zone_ids = [element(azurerm_private_dns_zone.postgres.*.id,0)]
  }

  private_service_connection {
    name                           = "${var.friendly_name_prefix}-pvsc-pg"
    private_connection_resource_id = var.postgres_server_id
    is_manual_connection = false
    subresource_names    = ["postgresqlServer"]
  }
}

