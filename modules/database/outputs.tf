output "address" {
  value = var.flexible_server ? "${element(azurerm_postgresql_flexible_server.tfe_pg.*.fqdn,0)}:5432" : "${element(azurerm_postgresql_server.tfe_pg.*.fqdn,0)}:5432"

  description = "The address of the PostgreSQL database."
}
output "name" {
  # This is the name of the default database created with the server.
  value = var.flexible_server ? "postgres" : element(azurerm_postgresql_database.tfe_pg_db.*.name,0)

  description = "The name of the PostgreSQL database."
}

output "server" {
  value = var.flexible_server ? azurerm_postgresql_flexible_server.tfe_pg[0] : azurerm_postgresql_server.tfe_pg[0]

  description = "The PostgreSQL server."
}
