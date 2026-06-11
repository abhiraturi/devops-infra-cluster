variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  default     = "devops-project-rg"
}

variable "location" {
  description = "Azure region for deployment"
  default     = "East US"
}

variable "node_count" {
  description = "Number of nodes in the cluster"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "Size of the VM nodes"
  default     = "Standard_B2s"
}