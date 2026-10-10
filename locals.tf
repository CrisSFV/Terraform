locals {
  resource_group_name = "rg-${var.project_name}-${var.environment}-${var.location}-001"

  virtual_network_name = "vnet-${title(var.project_name)}-${var.environment}-${var.location}-001"

  subnet_address_prefixes = {
    app       = "10.0.1.0/24"
    db        = "10.0.2.0/24"
    vm        = "10.0.3.0/24"
    endpoints = "10.0.4.0/24"
    bastion   = "10.0.5.0/24"
  }

  common_tags = merge(
    var.tags,
    {
      project     = var.project_name
      environment = var.environment
      location    = var.location
    }
  )
}
