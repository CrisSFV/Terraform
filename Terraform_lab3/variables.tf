variable "subscription_id" {
  description = "Suscripción Azure for Students."
  type        = string
  default     = "8f447e01-3ab5-41d1-86cc-22f221fdde81"
}

variable "location" {
  description = "Región con VM gratuita, PostgreSQL y Bastion Developer disponibles para la suscripción."
  type        = string
  default     = "northcentralus"
}

variable "vm_size" {
  description = "Tamaño de la VM incluido en los servicios gratuitos."
  type        = string
  default     = "Standard_B2ats_v2"
}

variable "vm_admin_username" {
  description = "Usuario administrador de la VM."
  type        = string
  default     = "azureadmin"
}

variable "postgres_admin_username" {
  description = "Usuario administrador de PostgreSQL."
  type        = string
  default     = "adminpgdev"
}

variable "postgres_version" {
  description = "Versión de PostgreSQL."
  type        = string
  default     = "17"
}

variable "tags" {
  description = "Etiquetas comunes para los recursos."
  type        = map(string)
  default = {
    managed_by  = "terraform"
    project     = "utvt-lab3"
    environment = "dev"
  }
}
