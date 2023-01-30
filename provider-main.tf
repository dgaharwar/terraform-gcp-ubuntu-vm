#########################
## GCP Provider - Main ##
#########################

# Define Terraform provider
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.84.0"
    }
  }
} 

provider "google" { 
  project     = var.gcp_project 
  region      = var.gcp_region 
  credentials = jsonencode(local.credential) 
}
