output "application_name" {
  value = var.project_name
}

output "unique_name" {
  value = azurerm_resource_group.main.name
}