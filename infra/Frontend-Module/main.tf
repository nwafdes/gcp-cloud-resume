terraform {
  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 6.0"
    }
  }
  backend "gcs" {
    bucket = "sahaba-tf-bucket"
    prefix = "frontend"
  }
}

module "sahaba-gcp-Frontend" {
  source = "../Frontend"
  bucket_name = "sahaba-gcp-bucket"
  location = "me-central1"
  project_id = "sahaba-466907"
}