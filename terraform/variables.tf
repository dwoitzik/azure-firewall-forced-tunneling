variable "location" {
  type        = string
  description = "Azure Region for the deployment"
  default     = "westeurope"
}

variable "rg_name" {
  type        = string
  description = "Name of the Resource Group"
  default     = "rg-forced-tunneling-demo"
}

variable "hub_vnet_cidr" {
  type        = list(string)
  description = "CIDR block for the Hub VNet"
  default     = ["10.0.0.0/16"]
}

variable "spoke_vnet_cidr" {
  type        = list(string)
  description = "CIDR block for the Spoke VNet"
  default     = ["10.1.0.0/16"]
}

variable "fw_subnet_cidr" {
  type        = list(string)
  description = "CIDR block for AzureFirewallSubnet"
  default     = ["10.0.1.0/26"]
}

variable "spoke_subnet_cidr" {
  type        = list(string)
  description = "CIDR block for Spoke Workload Subnet"
  default     = ["10.1.1.0/24"]
}

variable "environment" {
  type        = string
  description = "The environment name (e.g., dev, test, prod)."
  default     = "dev"
}

variable "tags" {
  type        = map(string)
  description = "Standard tags to apply to all resources."
  default     = {}
}
