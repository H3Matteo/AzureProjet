output "vm_public_ip" {
  description = "Adresse IP publique de la VM"
  value       = azurerm_public_ip.public_ip.ip_address
}

output "storage_account_url" {
  description = "URL du compte de stockage"
  value       = azurerm_storage_account.storage.primary_blob_endpoint
}

