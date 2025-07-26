terraform {
  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 6.0"
    }
  }
}

provider "google" {
  project = "sahaba-466907"
  region  = "me-central1"
}

resource "google_storage_bucket" "static" {
  project       = "sahaba-466907"
  name          = "sahaba-tf-bucket"
  location      = "me-central1"               # Example: "me-central1"
  storage_class = "STANDARD"                 # Standard storage for frequent access
  force_destroy = true                       # Automatically deletes non-empty bucket

  uniform_bucket_level_access = true         # Disables fine-grained object-level ACLs
}
