# declare the current bucket
locals {
  function_bucket = "sahaba-gcp"
}

# archive the python project
data "archive_file" "function_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../app/Backend"
  output_path = "${path.module}/backend-function.zip"
  # execlude un-necessary files, directories
   excludes    = ["__pycache__/*", ".pytest_cache/*", "*.pyc", "temp*"]
}

# upload the object into the bucket (required for cloudrun)
resource "google_storage_bucket_object" "archive" {
  name   = "backend-function.zip"
  bucket = local.function_bucket
  source = data.archive_file.function_zip.output_path
  content_type = "application/zip"
}

#🌟 Cloudrun requires you zip file to be uploaded to a bucket
################################################################3

resource "google_cloudfunctions2_function" "function" {
  name        = var.function_name
  description = "My function"
  location = "me-central1"

   build_config {
    runtime     = "python311"
    entry_point    = "hello_http"
    source {
      storage_source {
        bucket = local.function_bucket
        object = google_storage_bucket_object.archive.name
      }
    }
  }
  service_config {
    max_instance_count = 3
    available_memory   = "256M"
    ingress_settings   = "ALLOW_ALL"

    environment_variables = {
        "DATABASE_NAME" = var.database_name
        "COLLECTION_NAME" = var.collection_name
        "DOCUMENT_NAME" = var.document
        "FIELD_NAME" = var.field_name
    }
  }
}



output "trigger_url"{
    value = google_cloudfunctions2_function.function.url
}

# allow unauthenticated invokations
resource "google_cloud_run_service_iam_binding" "invoker" {
  # name of the function
  service = var.function_name
  # name of the project and location
  project        = var.project_id
  location = "me-central1"
  members = ["allUsers"]
  role   = "roles/run.invoker"
}