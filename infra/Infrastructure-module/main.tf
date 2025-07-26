terraform {
  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 6.0"
    }
  }
  backend "gcs" {
    bucket = "sahaba-tf-bucket"
    prefix = "backend"
  }
}

locals {
  services = [
    "cloudfunctions.googleapis.com",
    "run.googleapis.com",
    "firestore.googleapis.com",
    "cloudbuild.googleapis.com"
  ]
}

resource "google_project_service" "enabled_apis" {
  for_each = toset(local.services)

  project = "sahaba-466907"
  service = each.value

  disable_on_destroy = false  # keep the API enabled when running `terraform destroy`
}

provider "google" {
  project = "sahaba-466907"
  region  = "me-central1"
}


data "terraform_remote_state" "frontend" {
  backend = "gcs"
  config = {
    bucket = "sahaba-tf-bucket"
    prefix = "frontend"        # ←-same prefix as above
  }
}

module "gcp-backend" {
  source          = "../Infrastructure"
  project_id         = "sahaba-466907"
  database_name   = "sahaba-gcp-db"
  collection_name = "sahaba-gcp-collection"
  document        = "sahaba-gcp-document"
  function_name = "sahaba-gcp-funciton"
  field_name = "Vistor_Counter"
  # you must have permission to read the file from the bucket
  bucket_name = data.terraform_remote_state.frontend.outputs.bucket_name
}   