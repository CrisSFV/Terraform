
variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "location" {
  description = "Región de Azure donde se desplegará la infraestructura"
  type        = string
}

variable "vnet_address_space" {
  description = "Rangos CIDR de la red virtual"
  type        = list(string)
}

variable "admin_username" {
  description = "Usuario administrador de la VM Linux."
  type        = string
  default     = "azureuser"
}

variable "admin_ssh_public_key" {
  description = "Clave pública SSH para acceder a la VM a través de Azure Bastion."
  type        = string
  sensitive   = true
}

variable "postgres_admin_username" {
  description = "Usuario administrador del servidor PostgreSQL."
  type        = string
  default     = "pgadmin"
}

variable "postgres_admin_password" {
  description = "Contraseña del servidor PostgreSQL. Debe cumplir las reglas de Azure."
  type        = string
  sensitive   = true
}

variable "postgres_version" {
  description = "Versión mayor de PostgreSQL Flexible Server."
  type        = string
  default     = "16"
}

variable "vm_size" {
  description = "Tamaño de la VM Linux."
  type        = string
  default     = "Standard_B2ats_v2"
}

variable "storage_replication_type" {
  description = "Tipo de replicación de la cuenta de almacenamiento."
  type        = string
  default     = "LRS"
}

variable "create_bastion" {
  description = "Crea Azure Bastion para administración privada de la VM."
  type        = bool
  default     = true
}

variable "create_vm" {
  description = "Crea la VM Linux y sus recursos de red."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Etiquetas de los recursos"
  type        = map(string)
  default     = {}
}

variable "apllication_name" {
  description = "Nombre de la aplicación"
  type        = string
  default     = "integradora"
}

variable "environment" {
  description = "Entorno donde se desplegará la infraestructura."
  type        = string
  default     = "dev"
}

variable "length" {
  description = "The length of the random string to generate."
  type        = number
  default     = 5
}

# Otros tipos de variables que pueden ser usadas en la configuración
variable "enable_monitoring" {
  description = "Enable Monitoring"
  type        = bool
  default     = true
}

variable "regions" {
  description = "Lista de regiones donde se desplegará la infraestructura."
  type        = list(string)
  default     = ["us-east-1", "us-east-2", "us-west-1", "us-west-2"]
}

variable "evironment_tags" {
  description = "El entorno donde se desplegará la infraestructura."
  type        = map(string)
  default = {
    dev = "development"
    prd = "production"
  }
}

variable "application_config" {
  description = "Configuración de la aplicación"
  type = object({
    version      = string
    maintainer   = string
    dependencies = list(string)
  })
  default = {
    version      = "1.0.0"
    maintainer   = "Cristian Santana"
    dependencies = ["dependency1", "dependency2"]
  }
}

variable "allowed_networks" {
  description = "Lista de IPs permitidas para acceder a la aplicación."
  type        = list(string)
  default     = ["10.0.0.0/16", "10.1.0.0/16"]
}