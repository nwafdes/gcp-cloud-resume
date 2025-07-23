terraform {
  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 6.0"
    }
  }
}

provider "google" {
  project = "fiery-protocol-466303-p6"
  region  = "me-central1"
}

module "gcp-backend" {
  source          = "../Infrastructure"
  project_id         = "fiery-protocol-466303-p6"
  database_name   = "sahaba-gcp-db"
  collection_name = "sahaba-gcp-collection"
  document        = "sahaba-gcp-document"
  function_name = "sahaba-gcp-funciton"
  field_name = "Vistor_Counter"
}   