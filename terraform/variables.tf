variable "location" {
  type        = string
  description = "Azure region where resources will be deployed."
  default     = "westeurope"
}

variable "environment" {
  type        = string
  description = "The environment name (e.g., dev, test, prod)."
}

variable "tags" {
  type        = map(string)
  description = "Standard tags to apply to all resources."
  default     = {}
}
