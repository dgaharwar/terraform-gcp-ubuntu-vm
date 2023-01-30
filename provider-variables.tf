##############################
## GCP Provider - Variables ##
##############################

# GCP authentication file
variable "gcp_auth_file" {
  type        = string
  description = "GCP authentication file"
}

# define GCP project name
variable "gcp_project" {
  type        = string
  description = "GCP project name"
}

# define GCP region
variable "gcp_region" {
  type        = string
  description = "GCP region"
}

# define GCP region
variable "gcp_zone" {
  type        = string
  description = "GCP zone"
}

variable "gcp_private_key" { 
  type = string 
} 

variable "gcp_cred" { 
  type = map 
} 

locals {
  credential = merge(var.gcp_cred, {private_key = "${var.gcp_private_key}"}) 
}
