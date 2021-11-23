resource "random_string" "tfe_pg_password" {
  length  = 24
  special = true
}

resource "azurerm_postgresql_flexible_server" "tfe_pg" {
  count = var.flexible_server ? 1 :0
  location            = var.location
  name                = "${var.friendly_name_prefix}-pg"
  resource_group_name = var.resource_group_name

  administrator_login    = var.database_user
  administrator_password = random_string.tfe_pg_password.result
  backup_retention_days  = var.database_backup_retention_days
  delegated_subnet_id    = var.database_subnet_id
  private_dns_zone_id    = var.database_private_dns_zone_id
  sku_name               = var.database_machine_type
  storage_mb             = var.database_size_mb
  tags                   = var.tags
  version                = var.database_version
}


resource "azurerm_postgresql_server" "tfe_pg" {
  count = !var.flexible_server ? 1 :0
  name                = "${var.friendly_name_prefix}-pg"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name   = var.database_machine_type
  storage_mb = var.database_size_mb
  version    = var.database_version

  administrator_login          = var.database_user
  administrator_login_password = random_string.tfe_pg_password.result

  backup_retention_days        = var.database_backup_retention_days
  geo_redundant_backup_enabled = var.database_geo_redundant_backup_enabled
  auto_grow_enabled            = var.database_auto_grow_enabled
  ssl_enforcement_enabled      = var.database_ssl_enforcement_enabled

  tags = var.tags
}

resource "azurerm_postgresql_database" "tfe_pg_db" {
  count = !var.flexible_server ? 1 :0
  name                = "${var.friendly_name_prefix}-pg-db"
  resource_group_name = var.resource_group_name

  server_name = element(azurerm_postgresql_server.tfe_pg.*.name,0)
  charset     = "UTF8"
  collation   = "English_United States.1252"
}