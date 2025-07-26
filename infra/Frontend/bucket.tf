# ───────────────────────────────────────────────
# 🌍 Enable Required Google Cloud APIs
# ───────────────────────────────────────────────

locals {
  storage_api = "storage.googleapis.com"  # Identifier for the Cloud Storage API
}

resource "google_project_service" "enabled_apis" {
  project              = var.project_id
  service              = local.storage_api
  disable_on_destroy   = false  # Automatically disables the API when the project is destroyed
}

# ───────────────────────────────────────────────
# 🪣 Create GCS Bucket to Host Static Website
# ───────────────────────────────────────────────

resource "google_storage_bucket" "static" {
  project       = var.project_id
  name          = var.bucket_name
  location      = var.location               # Example: "me-central1"
  storage_class = "STANDARD"                 # Standard storage for frequent access
  force_destroy = true                       # Automatically deletes non-empty bucket

  website {
    main_page_suffix = "index.html"          # Entry point of the website
    not_found_page   = "404.html"            # Custom 404 error page
  }

  versioning {
    enabled = true                           # Enables versioning for safety
  }

  uniform_bucket_level_access = true         # Disables fine-grained object-level ACLs
  
}

# ───────────────────────────────────────────────
# 🌐 Make the Bucket Public (Anyone Can View)
# ───────────────────────────────────────────────

resource "google_storage_bucket_iam_member" "member" {
  provider = google
  bucket   = google_storage_bucket.static.name
  role     = "roles/storage.objectViewer"    # Grants read access to objects
  member   = "allUsers"                      # "allUsers" makes it publicly accessible
}

# ───────────────────────────────────────────────
# 📂 Upload Static Files to the Bucket
# ───────────────────────────────────────────────

# Define content types for each file
locals {
  content_type = {
    "index.html"       = "text/html"
    "interactions.js"  = "application/javascript"
  }
}

resource "google_storage_bucket_object" "default" {
  for_each = tomap(local.content_type)

  name         = each.key
  source       = "${path.module}/../../app/Frontend/${each.key}" # Path to static files
  content_type = each.value
  bucket       = google_storage_bucket.static.id
}

output "bucket_name" {
  value = var.bucket_name
}