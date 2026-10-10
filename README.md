# Práctica Terraform: Landing Zone Azure

Este repositorio implementa una arquitectura de referencia basada en la VNet `10.0.0.0/16` del diagrama entregado:

- `snet-app` (`10.0.1.0/24`): integración regional de App Service y delegación `Microsoft.Web/serverFarms`.
- `snet-db` (`10.0.2.0/24`): PostgreSQL Flexible Server mediante acceso privado VNet-injected.
- `snet-vm` (`10.0.3.0/24`): VM Linux sin IP pública.
- `snet-endpoints` (`10.0.4.0/24`): Private Endpoint del Blob Storage.
- `AzureBastionSubnet` (`10.0.5.0/24`): administración privada de la VM.

También se crean Private DNS Zones, Log Analytics, Application Insights, identidad administrada del App Service, una cuenta de almacenamiento con contenedor privado y Azure Bastion.

## Requisitos

- Terraform `>= 1.13.0`.
- Suscripción de Azure con permisos para crear los recursos.
- Azure CLI autenticado (`az login`) o variables de autenticación del proveedor.
- Una clave SSH pública y una contraseña segura para PostgreSQL.

## Uso

1. Copiar `terraform.tfvars` a un archivo local no versionado y sustituir los valores `REPLACE_WITH...`.
2. Inicializar:

   ```powershell
   terraform init
   ```

3. Revisar y guardar el plan:

   ```powershell
   terraform plan -out=tfplan
   ```

4. Aplicar solo después de revisar costos, región y nombres:

   ```powershell
   terraform apply tfplan
   ```

5. Obtener endpoints:

   ```powershell
   terraform output
   ```

La cuenta de almacenamiento usa acceso público deshabilitado. PostgreSQL Flexible Server no usa un `azurerm_private_endpoint`: su modo privado soportado por AzureRM es la inyección en una subred delegada y una zona DNS privada, que es la implementación equivalente al enlace privado del diagrama.

## Evidencias

El documento [evidencias-practica.docx](./evidencias-practica.docx) contiene el objetivo, la relación con el diagrama, el procedimiento, la evidencia de validación y espacios para incorporar capturas de `terraform plan`, `terraform apply`, Portal de Azure y outputs reales después de ejecutar la práctica en una suscripción.
