data "azurerm_client_config" "current" {}

resource "random_string" "suffix" {
  length  = 6
  lower   = true
  numeric = true
  special = false
  upper   = false
}

resource "random_password" "vm_admin" {
  length           = 24
  special          = true
  override_special = "!#%*-_=+"
  min_lower        = 2
  min_upper        = 2
  min_numeric      = 2
  min_special      = 2
}

resource "random_password" "postgres_admin" {
  length           = 24
  special          = true
  override_special = "!#%*-_=+"
  min_lower        = 2
  min_upper        = 2
  min_numeric      = 2
  min_special      = 2
}

resource "azurerm_resource_group" "lab" {
  name     = "rg-utvt-lab3-dev-ncus-001"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "lab" {
  name                = "vnet-utvt-lab3-dev-ncus-001"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  address_space       = ["10.20.0.0/16"]
  tags                = var.tags
}

resource "azurerm_virtual_network" "app" {
  name                = "vnet-utvt-lab3-app-dev-mxc-001"
  location            = var.app_location
  resource_group_name = azurerm_resource_group.lab.name
  address_space       = ["10.30.0.0/16"]
  tags                = var.tags
}

resource "azurerm_virtual_network_peering" "lab_to_app" {
  name                      = "peer-lab-to-app"
  resource_group_name       = azurerm_resource_group.lab.name
  virtual_network_name      = azurerm_virtual_network.lab.name
  remote_virtual_network_id = azurerm_virtual_network.app.id
}

resource "azurerm_virtual_network_peering" "app_to_lab" {
  name                      = "peer-app-to-lab"
  resource_group_name       = azurerm_resource_group.lab.name
  virtual_network_name      = azurerm_virtual_network.app.name
  remote_virtual_network_id = azurerm_virtual_network.lab.id
}

resource "azurerm_subnet" "app" {
  name                 = "snet-utvt-lab3-app-dev-mxc-001"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.app.name
  address_prefixes     = ["10.30.1.0/24"]

  delegation {
    name = "app-service-delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "db" {
  name                 = "snet-utvt-lab3-db-dev-ncus-001"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab.name
  address_prefixes     = ["10.20.2.0/24"]

  delegation {
    name = "postgresql-delegation"

    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "vm" {
  name                 = "snet-utvt-lab3-vm-dev-ncus-001"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab.name
  address_prefixes     = ["10.20.3.0/24"]
}

resource "azurerm_network_security_group" "vm" {
  name                = "nsg-utvt-lab3-vm-dev-ncus-001"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  tags                = var.tags

  security_rule {
    name                       = "allow-rdp-from-bastion-developer"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "168.63.129.16/32"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "vm" {
  subnet_id                 = azurerm_subnet.vm.id
  network_security_group_id = azurerm_network_security_group.vm.id
}

resource "azurerm_bastion_host" "lab" {
  name                = "bas-utvt-lab3-dev-ncus-001"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  sku                 = "Developer"
  virtual_network_id  = azurerm_virtual_network.lab.id
  tags                = var.tags
}

resource "azurerm_network_interface" "vm" {
  name                = "nic-utvt-lab3-vm-dev-ncus-001"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                  = "vm-utvt-lab3-dev-ncus-001"
  computer_name         = "vmlab3win01"
  location              = azurerm_resource_group.lab.location
  resource_group_name   = azurerm_resource_group.lab.name
  size                  = var.vm_size
  admin_username        = var.vm_admin_username
  admin_password        = random_password.vm_admin.result
  network_interface_ids = [azurerm_network_interface.vm.id]
  tags                  = var.tags

  os_disk {
    name                 = "osdisk-utvt-lab3-vm-dev-ncus-001"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 64
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-smalldisk-g2"
    version   = "latest"
  }
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "vm" {
  virtual_machine_id    = azurerm_windows_virtual_machine.vm.id
  location              = azurerm_resource_group.lab.location
  enabled               = true
  daily_recurrence_time = "2300"
  timezone              = "Central Standard Time (Mexico)"
  tags                  = var.tags

  notification_settings {
    enabled = false
  }
}

resource "azurerm_private_dns_zone" "postgres" {
  name                = "lab3.private.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.lab.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = "postgres-vnet-link"
  resource_group_name   = azurerm_resource_group.lab.name
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = azurerm_virtual_network.lab.id
  registration_enabled  = false
  tags                  = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres_app" {
  name                  = "postgres-app-vnet-link"
  resource_group_name   = azurerm_resource_group.lab.name
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = azurerm_virtual_network.app.id
  registration_enabled  = false
  tags                  = var.tags
}

resource "azurerm_postgresql_flexible_server" "lab" {
  name                          = "psql-utvt-lab3-dev-${random_string.suffix.result}"
  location                      = azurerm_resource_group.lab.location
  resource_group_name           = azurerm_resource_group.lab.name
  version                       = var.postgres_version
  delegated_subnet_id           = azurerm_subnet.db.id
  private_dns_zone_id           = azurerm_private_dns_zone.postgres.id
  public_network_access_enabled = false
  administrator_login           = var.postgres_admin_username
  administrator_password        = random_password.postgres_admin.result
  storage_mb                    = 32768
  sku_name                      = "B_Standard_B1ms"
  backup_retention_days         = 7
  tags                          = var.tags
  depends_on                    = [azurerm_private_dns_zone_virtual_network_link.postgres]

  lifecycle {
    ignore_changes = [zone]
  }
}

resource "azurerm_postgresql_flexible_server_database" "school_management" {
  name      = "school_management"
  server_id = azurerm_postgresql_flexible_server.lab.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

resource "azurerm_key_vault" "lab" {
  name                       = "kv-utvt-lab3-${random_string.suffix.result}"
  location                   = azurerm_resource_group.lab.location
  resource_group_name        = azurerm_resource_group.lab.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  tags                       = var.tags
}

resource "azurerm_role_assignment" "key_vault_admin" {
  scope                = azurerm_key_vault.lab.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "time_sleep" "rbac_propagation" {
  depends_on      = [azurerm_role_assignment.key_vault_admin]
  create_duration = "120s"
}

resource "azurerm_key_vault_secret" "postgres_password" {
  name         = "postgres-password"
  value        = random_password.postgres_admin.result
  key_vault_id = azurerm_key_vault.lab.id
  depends_on   = [time_sleep.rbac_propagation]
}

resource "azurerm_log_analytics_workspace" "lab" {
  name                = "log-utvt-lab3-dev-ncus-001"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_application_insights" "lab" {
  name                = "appi-utvt-lab3-dev-ncus-001"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  workspace_id        = azurerm_log_analytics_workspace.lab.id
  application_type    = "java"
  tags                = var.tags
}

resource "azurerm_service_plan" "lab" {
  name                = "asp-utvt-lab3-dev-mxc-001"
  location            = var.app_location
  resource_group_name = azurerm_resource_group.lab.name
  os_type             = "Linux"
  sku_name            = "B1"
  tags                = var.tags
}

resource "azurerm_linux_web_app" "api" {
  name                      = "app-utvt-lab3-api-${random_string.suffix.result}"
  location                  = azurerm_service_plan.lab.location
  resource_group_name       = azurerm_resource_group.lab.name
  service_plan_id           = azurerm_service_plan.lab.id
  https_only                = true
  virtual_network_subnet_id = azurerm_subnet.app.id
  tags                      = var.tags

  depends_on = [
    azurerm_virtual_network_peering.lab_to_app,
    azurerm_virtual_network_peering.app_to_lab,
    azurerm_private_dns_zone_virtual_network_link.postgres_app,
  ]

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on              = true
    vnet_route_all_enabled = true

    application_stack {
      java_server         = "JAVA"
      java_server_version = "25"
      java_version        = "25"
    }
  }

  app_settings = {
    SPRING_PROFILES_ACTIVE                     = "azure"
    DB_HOST                                    = azurerm_postgresql_flexible_server.lab.fqdn
    DB_PORT                                    = "5432"
    DB_NAME                                    = azurerm_postgresql_flexible_server_database.school_management.name
    DB_USERNAME                                = var.postgres_admin_username
    DB_PASSWORD                                = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.postgres_password.versionless_id})"
    PORT                                       = "8080"
    APPLICATIONINSIGHTS_CONNECTION_STRING      = azurerm_application_insights.lab.connection_string
    ApplicationInsightsAgent_EXTENSION_VERSION = "~3"
    XDT_MicrosoftApplicationInsights_Mode      = "recommended"
  }
}

resource "azurerm_role_assignment" "key_vault_secrets_user" {
  scope                = azurerm_key_vault.lab.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_web_app.api.identity[0].principal_id
}
