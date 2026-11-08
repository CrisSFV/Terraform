output "resource_group_name" {
  description = "Nombre del grupo de recursos del laboratorio."
  value       = azurerm_resource_group.lab.name
}

output "web_app_name" {
  description = "Nombre del App Service."
  value       = azurerm_linux_web_app.api.name
}

output "web_app_url" {
  description = "URL pública de la API."
  value       = "https://${azurerm_linux_web_app.api.default_hostname}"
}

output "key_vault_name" {
  description = "Nombre del Key Vault."
  value       = azurerm_key_vault.lab.name
}

output "postgres_fqdn" {
  description = "Host privado de PostgreSQL."
  value       = azurerm_postgresql_flexible_server.lab.fqdn
}

output "postgres_admin_username" {
  description = "Usuario administrador de PostgreSQL."
  value       = var.postgres_admin_username
}

output "postgres_admin_password" {
  description = "Contraseña del administrador de PostgreSQL."
  value       = random_password.postgres_admin.result
  sensitive   = true
}

output "vm_name" {
  description = "Nombre de la VM con pgAdmin."
  value       = azurerm_windows_virtual_machine.vm.name
}

output "vm_admin_username" {
  description = "Usuario administrador de la VM."
  value       = var.vm_admin_username
}

output "vm_admin_password" {
  description = "Contraseña del administrador de la VM."
  value       = random_password.vm_admin.result
  sensitive   = true
}
