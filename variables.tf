variable "name" {
  description = "Application name. Used in labels and the app:<name> tag."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{3,30}$", var.name))
    error_message = "name must be 3-30 characters: lowercase letters, digits and hyphens."
  }
}

variable "environment" {
  description = "Environment name (dev, staging or prod)."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "region" {
  description = "Linode region ID. Must match the region of the VPC subnet."
  type        = string
}

variable "subnet_id" {
  description = "ID of the VPC subnet to attach the private interface to."
  type        = number
}

variable "instance_type" {
  description = "Linode plan type. g6-nanode-1 is the cheapest shared-CPU plan."
  type        = string
  default     = "g6-nanode-1"
}

variable "image" {
  description = "Linode image ID."
  type        = string
  default     = "linode/ubuntu24.04"
}

variable "authorized_keys" {
  description = "SSH public keys installed for root. Password login is not configured by this module."
  type        = list(string)
  default     = []
}

variable "admin_ssh_cidrs" {
  description = "IPv4 CIDRs allowed to reach SSH (port 22). Empty means SSH is closed."
  type        = list(string)
  default     = []

  validation {
    condition     = !contains(var.admin_ssh_cidrs, "0.0.0.0/0")
    error_message = "SSH must not be open to 0.0.0.0/0. Use specific admin CIDRs."
  }
}

variable "backups_enabled" {
  description = "Enable the Linode Backup service (adds cost)."
  type        = bool
  default     = false
}

variable "user_data" {
  description = "Optional cloud-init user data (plain text). Applied at first boot only."
  type        = string
  default     = ""
}

variable "extra_tags" {
  description = "Additional tags, e.g. [\"owner:platform-team\"]."
  type        = list(string)
  default     = []
}
