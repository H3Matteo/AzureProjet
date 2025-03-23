variable "resource_group_name" {
  description = "Nom du groupe de ressources"
  type        = string
  default     = "ProjetMatteo"
}

variable "location" {
  description = "Région Azure"
  type        = string
  default     = "eastus"
}

variable "storage_account_name" {
  description = "Nom du compte de stockage"
  type        = string
  default     = "matteocomptestorage"
}

variable "vm_name" {
  description = "Nom de la machine virtuelle"
  type        = string
  default     = "MatteoVM"
}

variable "subscription_id" {
  description = "ID de la souscription Azure"
  type        = string
}

variable "postgres_admin_user" {
  type        = string
  description = "Nom d'utilisateur PostgreSQL"
}