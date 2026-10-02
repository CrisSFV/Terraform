locals {
  resource_group_name = "rg-${var.project_name}-${var.environment}-${var.location}-001"

  virtual_network_name = "vnet-${var.project_name}-${var.environment}-${var.location}-001"

  common_tags = merge(
    var.tags,
    {
      project     = var.project_name
      environment = var.environment
      location    = var.location
    }
  )
}
